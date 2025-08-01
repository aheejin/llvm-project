//===- UseDefAnalysis.cpp - Analysis for Transitive UseDef chains ---------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This file implements Analysis functions specific to slicing in Function.
//
//===----------------------------------------------------------------------===//

#include "mlir/Analysis/SliceAnalysis.h"
#include "mlir/Analysis/TopologicalSortUtils.h"
#include "mlir/IR/Block.h"
#include "mlir/IR/Operation.h"
#include "mlir/Interfaces/SideEffectInterfaces.h"
#include "mlir/Support/LLVM.h"
#include "llvm/ADT/STLExtras.h"
#include "llvm/ADT/SetVector.h"

///
/// Implements Analysis functions specific to slicing in Function.
///

using namespace mlir;

static void
getForwardSliceImpl(Operation *op, DenseSet<Operation *> &visited,
                    SetVector<Operation *> *forwardSlice,
                    const SliceOptions::TransitiveFilter &filter = nullptr) {
  if (!op)
    return;

  // Evaluate whether we should keep this use.
  // This is useful in particular to implement scoping; i.e. return the
  // transitive forwardSlice in the current scope.
  if (filter && !filter(op))
    return;

  for (Region &region : op->getRegions())
    for (Block &block : region)
      for (Operation &blockOp : block)
        if (forwardSlice->count(&blockOp) == 0) {
          // We don't have to check if the 'blockOp' is already visited because
          // there cannot be a traversal path from this nested op to the parent
          // and thus a cycle cannot be closed here. We still have to mark it
          // as visited to stop before visiting this operation again if it is
          // part of a cycle.
          visited.insert(&blockOp);
          getForwardSliceImpl(&blockOp, visited, forwardSlice, filter);
          visited.erase(&blockOp);
        }

  for (Value result : op->getResults())
    for (Operation *userOp : result.getUsers()) {
      // A cycle can only occur within a basic block (not across regions or
      // basic blocks) because the parent region must be a graph region, graph
      // regions are restricted to always have 0 or 1 blocks, and there cannot
      // be a def-use edge from a nested operation to an operation in an
      // ancestor region. Therefore, we don't have to but may use the same
      // 'visited' set across regions/blocks as long as we remove operations
      // from the set again when the DFS traverses back from the leaf to the
      // root.
      if (forwardSlice->count(userOp) == 0 && visited.insert(userOp).second)
        getForwardSliceImpl(userOp, visited, forwardSlice, filter);

      visited.erase(userOp);
    }

  forwardSlice->insert(op);
}

void mlir::getForwardSlice(Operation *op, SetVector<Operation *> *forwardSlice,
                           const ForwardSliceOptions &options) {
  DenseSet<Operation *> visited;
  visited.insert(op);
  getForwardSliceImpl(op, visited, forwardSlice, options.filter);
  if (!options.inclusive) {
    // Don't insert the top level operation, we just queried on it and don't
    // want it in the results.
    forwardSlice->remove(op);
  }

  // Reverse to get back the actual topological order.
  // std::reverse does not work out of the box on SetVector and I want an
  // in-place swap based thing (the real std::reverse, not the LLVM adapter).
  SmallVector<Operation *, 0> v(forwardSlice->takeVector());
  forwardSlice->insert(v.rbegin(), v.rend());
}

void mlir::getForwardSlice(Value root, SetVector<Operation *> *forwardSlice,
                           const SliceOptions &options) {
  DenseSet<Operation *> visited;
  for (Operation *user : root.getUsers()) {
    visited.insert(user);
    getForwardSliceImpl(user, visited, forwardSlice, options.filter);
    visited.erase(user);
  }

  // Reverse to get back the actual topological order.
  // std::reverse does not work out of the box on SetVector and I want an
  // in-place swap based thing (the real std::reverse, not the LLVM adapter).
  SmallVector<Operation *, 0> v(forwardSlice->takeVector());
  forwardSlice->insert(v.rbegin(), v.rend());
}

static LogicalResult getBackwardSliceImpl(Operation *op,
                                          DenseSet<Operation *> &visited,
                                          SetVector<Operation *> *backwardSlice,
                                          const BackwardSliceOptions &options) {
  if (!op || op->hasTrait<OpTrait::IsIsolatedFromAbove>())
    return success();

  // Evaluate whether we should keep this def.
  // This is useful in particular to implement scoping; i.e. return the
  // transitive backwardSlice in the current scope.
  if (options.filter && !options.filter(op))
    return success();

  auto processValue = [&](Value value) {
    if (auto *definingOp = value.getDefiningOp()) {
      if (backwardSlice->count(definingOp) == 0 &&
          visited.insert(definingOp).second)
        return getBackwardSliceImpl(definingOp, visited, backwardSlice,
                                    options);

      visited.erase(definingOp);
    } else if (auto blockArg = dyn_cast<BlockArgument>(value)) {
      if (options.omitBlockArguments)
        return success();

      Block *block = blockArg.getOwner();
      Operation *parentOp = block->getParentOp();
      // TODO: determine whether we want to recurse backward into the other
      // blocks of parentOp, which are not technically backward unless they flow
      // into us. For now, just bail.
      if (parentOp && backwardSlice->count(parentOp) == 0) {
        if (parentOp->getNumRegions() == 1 &&
            parentOp->getRegion(0).hasOneBlock()) {
          return getBackwardSliceImpl(parentOp, visited, backwardSlice,
                                      options);
        }
      }
    } else {
      return failure();
    }
    return success();
  };

  bool succeeded = true;

  if (!options.omitUsesFromAbove) {
    llvm::for_each(op->getRegions(), [&](Region &region) {
      // Walk this region recursively to collect the regions that descend from
      // this op's nested regions (inclusive).
      SmallPtrSet<Region *, 4> descendents;
      region.walk(
          [&](Region *childRegion) { descendents.insert(childRegion); });
      region.walk([&](Operation *op) {
        for (OpOperand &operand : op->getOpOperands()) {
          if (!descendents.contains(operand.get().getParentRegion()))
            if (!processValue(operand.get()).succeeded()) {
              return WalkResult::interrupt();
            }
        }
        return WalkResult::advance();
      });
    });
  }
  llvm::for_each(op->getOperands(), processValue);

  backwardSlice->insert(op);
  return success(succeeded);
}

LogicalResult mlir::getBackwardSlice(Operation *op,
                                     SetVector<Operation *> *backwardSlice,
                                     const BackwardSliceOptions &options) {
  DenseSet<Operation *> visited;
  visited.insert(op);
  LogicalResult result =
      getBackwardSliceImpl(op, visited, backwardSlice, options);

  if (!options.inclusive) {
    // Don't insert the top level operation, we just queried on it and don't
    // want it in the results.
    backwardSlice->remove(op);
  }
  return result;
}

LogicalResult mlir::getBackwardSlice(Value root,
                                     SetVector<Operation *> *backwardSlice,
                                     const BackwardSliceOptions &options) {
  if (Operation *definingOp = root.getDefiningOp()) {
    return getBackwardSlice(definingOp, backwardSlice, options);
  }
  Operation *bbAargOwner = cast<BlockArgument>(root).getOwner()->getParentOp();
  return getBackwardSlice(bbAargOwner, backwardSlice, options);
}

SetVector<Operation *>
mlir::getSlice(Operation *op, const BackwardSliceOptions &backwardSliceOptions,
               const ForwardSliceOptions &forwardSliceOptions) {
  SetVector<Operation *> slice;
  slice.insert(op);

  unsigned currentIndex = 0;
  SetVector<Operation *> backwardSlice;
  SetVector<Operation *> forwardSlice;
  while (currentIndex != slice.size()) {
    auto *currentOp = (slice)[currentIndex];
    // Compute and insert the backwardSlice starting from currentOp.
    backwardSlice.clear();
    LogicalResult result =
        getBackwardSlice(currentOp, &backwardSlice, backwardSliceOptions);
    assert(result.succeeded());
    (void)result;
    slice.insert_range(backwardSlice);

    // Compute and insert the forwardSlice starting from currentOp.
    forwardSlice.clear();
    getForwardSlice(currentOp, &forwardSlice, forwardSliceOptions);
    slice.insert_range(forwardSlice);
    ++currentIndex;
  }
  return topologicalSort(slice);
}

/// Returns true if `value` (transitively) depends on iteration-carried values
/// of the given `ancestorOp`.
static bool dependsOnCarriedVals(Value value,
                                 ArrayRef<BlockArgument> iterCarriedArgs,
                                 Operation *ancestorOp) {
  // Compute the backward slice of the value.
  SetVector<Operation *> slice;
  BackwardSliceOptions sliceOptions;
  sliceOptions.filter = [&](Operation *op) {
    return !ancestorOp->isAncestor(op);
  };
  LogicalResult result = getBackwardSlice(value, &slice, sliceOptions);
  assert(result.succeeded());
  (void)result;

  // Check that none of the operands of the operations in the backward slice are
  // loop iteration arguments, and neither is the value itself.
  SmallPtrSet<Value, 8> iterCarriedValSet(llvm::from_range, iterCarriedArgs);
  if (iterCarriedValSet.contains(value))
    return true;

  for (Operation *op : slice)
    for (Value operand : op->getOperands())
      if (iterCarriedValSet.contains(operand))
        return true;

  return false;
}

/// Utility to match a generic reduction given a list of iteration-carried
/// arguments, `iterCarriedArgs` and the position of the potential reduction
/// argument within the list, `redPos`. If a reduction is matched, returns the
/// reduced value and the topologically-sorted list of combiner operations
/// involved in the reduction. Otherwise, returns a null value.
///
/// The matching algorithm relies on the following invariants, which are subject
/// to change:
///  1. The first combiner operation must be a binary operation with the
///     iteration-carried value and the reduced value as operands.
///  2. The iteration-carried value and combiner operations must be side
///     effect-free, have single result and a single use.
///  3. Combiner operations must be immediately nested in the region op
///     performing the reduction.
///  4. Reduction def-use chain must end in a terminator op that yields the
///     next iteration/output values in the same order as the iteration-carried
///     values in `iterCarriedArgs`.
///  5. `iterCarriedArgs` must contain all the iteration-carried/output values
///     of the region op performing the reduction.
///
/// This utility is generic enough to detect reductions involving multiple
/// combiner operations (disabled for now) across multiple dialects, including
/// Linalg, Affine and SCF. For the sake of genericity, it does not return
/// specific enum values for the combiner operations since its goal is also
/// matching reductions without pre-defined semantics in core MLIR. It's up to
/// each client to make sense out of the list of combiner operations. It's also
/// up to each client to check for additional invariants on the expected
/// reductions not covered by this generic matching.
Value mlir::matchReduction(ArrayRef<BlockArgument> iterCarriedArgs,
                           unsigned redPos,
                           SmallVectorImpl<Operation *> &combinerOps) {
  assert(redPos < iterCarriedArgs.size() && "'redPos' is out of bounds");

  BlockArgument redCarriedVal = iterCarriedArgs[redPos];
  if (!redCarriedVal.hasOneUse())
    return nullptr;

  // For now, the first combiner op must be a binary op.
  Operation *combinerOp = *redCarriedVal.getUsers().begin();
  if (combinerOp->getNumOperands() != 2)
    return nullptr;
  Value reducedVal = combinerOp->getOperand(0) == redCarriedVal
                         ? combinerOp->getOperand(1)
                         : combinerOp->getOperand(0);

  Operation *redRegionOp =
      iterCarriedArgs.front().getOwner()->getParent()->getParentOp();
  if (dependsOnCarriedVals(reducedVal, iterCarriedArgs, redRegionOp))
    return nullptr;

  // Traverse the def-use chain starting from the first combiner op until a
  // terminator is found. Gather all the combiner ops along the way in
  // topological order.
  while (!combinerOp->mightHaveTrait<OpTrait::IsTerminator>()) {
    if (!isMemoryEffectFree(combinerOp) || combinerOp->getNumResults() != 1 ||
        !combinerOp->hasOneUse() || combinerOp->getParentOp() != redRegionOp)
      return nullptr;

    combinerOps.push_back(combinerOp);
    combinerOp = *combinerOp->getUsers().begin();
  }

  // Limit matching to single combiner op until we can properly test reductions
  // involving multiple combiners.
  if (combinerOps.size() != 1)
    return nullptr;

  // Check that the yielded value is in the same position as in
  // `iterCarriedArgs`.
  Operation *terminatorOp = combinerOp;
  if (terminatorOp->getOperand(redPos) != combinerOps.back()->getResults()[0])
    return nullptr;

  return reducedVal;
}
