//===-- Optimizer/Dialect/FIROpsSupport.h -- FIR op support -----*- C++ -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#ifndef FORTRAN_OPTIMIZER_DIALECT_FIROPSSUPPORT_H
#define FORTRAN_OPTIMIZER_DIALECT_FIROPSSUPPORT_H

#include "flang/Optimizer/Dialect/FIROps.h"
#include "mlir/Dialect/Func/IR/FuncOps.h"
#include "mlir/IR/BuiltinOps.h"

namespace fir {

/// The LLVM dialect represents volatile memory accesses as read and write
/// effects to an unknown memory location, but this may be overly conservative.
/// LLVM Language Reference only specifies that volatile memory accesses
/// must not be reordered relative to other volatile memory accesses, so it
/// is more precise to use a separate memory resource for volatile memory
/// accesses.
inline void addVolatileMemoryEffects(
    mlir::TypeRange type,
    llvm::SmallVectorImpl<
        mlir::SideEffects::EffectInstance<mlir::MemoryEffects::Effect>>
        &effects) {
  for (mlir::Type t : type) {
    if (fir::isa_volatile_type(t)) {
      effects.emplace_back(mlir::MemoryEffects::Read::get(),
                           fir::VolatileMemoryResource::get());
      effects.emplace_back(mlir::MemoryEffects::Write::get(),
                           fir::VolatileMemoryResource::get());
      break;
    }
  }
}

/// Return true iff the Operation is a call.
inline bool isaCall(mlir::Operation *op) {
  return mlir::isa<fir::CallOp>(op) || mlir::isa<fir::DispatchOp>(op) ||
         mlir::isa<mlir::func::CallOp>(op) ||
         mlir::isa<mlir::func::CallIndirectOp>(op);
}

/// Return true iff the Operation is a fir::CallOp, fir::DispatchOp,
/// mlir::CallOp, or mlir::CallIndirectOp and not pure
/// NB: This is not the same as `!pureCall(op)`.
inline bool impureCall(mlir::Operation *op) {
  // Should we also auto-detect that the called function is pure if its
  // arguments are not references?  For now, rely on a "pure" attribute.
  return op && isaCall(op) && !op->getAttr("pure");
}

/// Return true iff the Operation is a fir::CallOp, fir::DispatchOp,
/// mlir::CallOp, or mlir::CallIndirectOp and is also pure.
/// NB: This is not the same as `!impureCall(op)`.
inline bool pureCall(mlir::Operation *op) {
  // Should we also auto-detect that the called function is pure if its
  // arguments are not references?  For now, rely on a "pure" attribute.
  return op && isaCall(op) && op->getAttr("pure");
}

/// Get or create a FuncOp in a module.
///
/// If `module` already contains FuncOp `name`, it is returned. Otherwise, a new
/// FuncOp is created, and that new FuncOp is returned. A symbol table can
/// be provided to speed-up the lookups.
mlir::func::FuncOp createFuncOp(mlir::Location loc, mlir::ModuleOp module,
                                llvm::StringRef name, mlir::FunctionType type,
                                llvm::ArrayRef<mlir::NamedAttribute> attrs = {},
                                const mlir::SymbolTable *symbolTable = nullptr);

/// Get or create a GlobalOp in a module. A symbol table can be provided to
/// speed-up the lookups.
fir::GlobalOp createGlobalOp(mlir::Location loc, mlir::ModuleOp module,
                             llvm::StringRef name, mlir::Type type,
                             llvm::ArrayRef<mlir::NamedAttribute> attrs = {},
                             const mlir::SymbolTable *symbolTable = nullptr);

/// Attribute to mark Fortran entities with the CONTIGUOUS attribute.
constexpr llvm::StringRef getContiguousAttrName() { return "fir.contiguous"; }

/// Attribute to mark Fortran entities with the OPTIONAL attribute.
constexpr llvm::StringRef getOptionalAttrName() { return "fir.optional"; }

/// Attribute to mark Fortran entities with the TARGET attribute.
static constexpr llvm::StringRef getTargetAttrName() { return "fir.target"; }

/// Attribute to mark Fortran entities with the ASYNCHRONOUS attribute.
static constexpr llvm::StringRef getAsynchronousAttrName() {
  return "fir.asynchronous";
}

/// Attribute to mark Fortran entities with the VOLATILE attribute.
static constexpr llvm::StringRef getVolatileAttrName() {
  return "fir.volatile";
}

/// Attribute to mark that a function argument is a character dummy procedure.
/// Character dummy procedure have special ABI constraints.
static constexpr llvm::StringRef getCharacterProcedureDummyAttrName() {
  return "fir.char_proc";
}

/// Attribute to keep track of Fortran scoping information for a symbol.
static constexpr llvm::StringRef getSymbolAttrName() {
  return "fir.bindc_name";
}

/// Attribute to mark a function that takes a host associations argument.
static constexpr llvm::StringRef getHostAssocAttrName() {
  return "fir.host_assoc";
}

/// Attribute to link an internal procedure to its host procedure symbol.
static constexpr llvm::StringRef getHostSymbolAttrName() {
  return "fir.host_symbol";
}

/// Attribute containing the original name of a function from before the
/// ExternalNameConverision pass runs
static constexpr llvm::StringRef getInternalFuncNameAttrName() {
  return "fir.internal_name";
}

/// Attribute to mark alloca that have been given a lifetime marker so that
/// later pass do not try adding new ones.
static constexpr llvm::StringRef getHasLifetimeMarkerAttrName() {
  return "fir.has_lifetime";
}

/// Does the function, \p func, have a host-associations tuple argument?
/// Some internal procedures may have access to host procedure variables.
bool hasHostAssociationArgument(mlir::func::FuncOp func);

/// Is the function, \p func an internal procedure ?
/// Some internal procedures may have access to saved host procedure
/// variables even when they do not have a tuple argument.
inline bool isInternalProcedure(mlir::func::FuncOp func) {
  return func->hasAttr(fir::getHostSymbolAttrName());
}

/// Tell if \p value is:
///   - a function argument that has attribute \p attributeName
///   - or, the result of fir.alloca/fir.allocmem op that has attribute \p
///     attributeName
///   - or, the result of a fir.address_of of a fir.global that has attribute \p
///     attributeName
///   - or, a fir.box loaded from a fir.ref<fir.box> that matches one of the
///     previous cases.
bool valueHasFirAttribute(mlir::Value value, llvm::StringRef attributeName);

/// A more conservative version of valueHasFirAttribute().
/// If `value` is one of the operation/function-argument cases listed
/// for valueHasFirAttribute():
///   * if any of the `attributeNames` attributes is set, then the function
///     will return true.
///   * otherwise, it will return false.
///
/// Otherwise, the function will return true indicating that the attributes
/// may actually be set but we were not able to reach the point of definition
/// to confirm that.
bool valueMayHaveFirAttributes(mlir::Value value,
                               llvm::ArrayRef<llvm::StringRef> attributeNames);

/// Scan the arguments of a FuncOp to determine if any arguments have the
/// attribute `attr` placed on them. This can be used to determine if the
/// function has any host associations, for example.
bool anyFuncArgsHaveAttr(mlir::func::FuncOp func, llvm::StringRef attr);

/// Unwrap integer constant from an mlir::Value.
std::optional<std::int64_t> getIntIfConstant(mlir::Value value);

static constexpr llvm::StringRef getAdaptToByRefAttrName() {
  return "adapt.valuebyref";
}

static constexpr llvm::StringRef getFuncPureAttrName() {
  return "fir.func_pure";
}

static constexpr llvm::StringRef getFuncElementalAttrName() {
  return "fir.func_elemental";
}

static constexpr llvm::StringRef getFuncRecursiveAttrName() {
  return "fir.func_recursive";
}

static constexpr llvm::StringRef getFortranProcedureFlagsAttrName() {
  return "fir.proc_attrs";
}

// Attribute for an alloca that is a trivial adaptor for converting a value to
// pass-by-ref semantics for a VALUE parameter. The optimizer may be able to
// eliminate these.
// Template is used to avoid compiler errors in places that don't include
// FIRBuilder.h
template <typename Builder>
inline mlir::NamedAttribute getAdaptToByRefAttr(Builder &builder) {
  return {mlir::StringAttr::get(builder.getContext(),
                                fir::getAdaptToByRefAttrName()),
          builder.getUnitAttr()};
}

bool isDummyArgument(mlir::Value v);

template <fir::FortranProcedureFlagsEnum Flag>
inline bool hasProcedureAttr(fir::FortranProcedureFlagsEnumAttr flags) {
  return flags && bitEnumContainsAny(flags.getValue(), Flag);
}

template <fir::FortranProcedureFlagsEnum Flag>
inline bool hasProcedureAttr(mlir::Operation *op) {
  if (auto firCallOp = mlir::dyn_cast<fir::CallOp>(op))
    return hasProcedureAttr<Flag>(firCallOp.getProcedureAttrsAttr());
  if (auto firCallOp = mlir::dyn_cast<fir::DispatchOp>(op))
    return hasProcedureAttr<Flag>(firCallOp.getProcedureAttrsAttr());
  return hasProcedureAttr<Flag>(
      op->getAttrOfType<fir::FortranProcedureFlagsEnumAttr>(
          getFortranProcedureFlagsAttrName()));
}

inline bool hasBindcAttr(mlir::Operation *op) {
  return hasProcedureAttr<fir::FortranProcedureFlagsEnum::bind_c>(op);
}

/// Get the allocation size of a given alloca if it has compile time constant
/// size.
std::optional<int64_t> getAllocaByteSize(fir::AllocaOp alloca,
                                         const mlir::DataLayout &dl,
                                         const fir::KindMapping &kindMap);

/// Return true, if \p rebox operation keeps the input array
/// continuous if it is initially continuous.
/// When \p checkWhole is false, then the checking is only done
/// for continuity in the innermost dimension, otherwise,
/// the checking is done for continuity of the whole result of rebox.
/// The caller may specify \p mayHaveNonDefaultLowerBounds, if it is known,
/// to allow better handling of the rebox operations representing
/// full array slices.
bool reboxPreservesContinuity(fir::ReboxOp rebox,
                              bool mayHaveNonDefaultLowerBounds = true,
                              bool checkWhole = true);

/// Return true, if \p embox operation produces a contiguous
/// entity.
/// When \p checkWhole is false, then the checking is only done
/// for continuity in the innermost dimension, otherwise,
/// the checking is done for continuity of the whole result of embox
bool isContiguousEmbox(fir::EmboxOp embox, bool checkWhole = true);

} // namespace fir

#endif // FORTRAN_OPTIMIZER_DIALECT_FIROPSSUPPORT_H
