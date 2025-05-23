; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc -mtriple=riscv32 -mattr=+m,+v,+zvfhmin,+zvfbfmin -verify-machineinstrs < %s | FileCheck %s --check-prefixes=CHECK,VLA,CHECK32
; RUN: llc -mtriple=riscv64 -mattr=+m,+v,+zvfhmin,+zvfbfmin -verify-machineinstrs < %s | FileCheck %s --check-prefixes=CHECK,VLA,CHECK64
; RUN: llc -mtriple=riscv32 -mattr=+m,+v,+zvfh,+zvfbfmin -verify-machineinstrs < %s | FileCheck %s --check-prefixes=CHECK,VLA,CHECK32
; RUN: llc -mtriple=riscv64 -mattr=+m,+v,+zvfh,+zvfbfmin -verify-machineinstrs < %s | FileCheck %s --check-prefixes=CHECK,VLA,CHECK64

; RUN: llc -mtriple=riscv32 -mattr=+m,+v,+zvfhmin,+zvfbfmin -early-live-intervals -verify-machineinstrs < %s | FileCheck %s --check-prefixes=CHECK,VLA,CHECK32
; RUN: llc -mtriple=riscv64 -mattr=+m,+v,+zvfhmin,+zvfbfmin -early-live-intervals -verify-machineinstrs < %s | FileCheck %s --check-prefixes=CHECK,VLA,CHECK64
; RUN: llc -mtriple=riscv32 -mattr=+m,+v,+zvfh,+zvfbfmin -early-live-intervals -verify-machineinstrs < %s | FileCheck %s --check-prefixes=CHECK,VLA,CHECK32
; RUN: llc -mtriple=riscv64 -mattr=+m,+v,+zvfh,+zvfbfmin -early-live-intervals -verify-machineinstrs < %s | FileCheck %s --check-prefixes=CHECK,VLA,CHECK64

; RUN: llc < %s -mtriple=riscv32 -mattr=+m,+v,+zvfhmin,+zvfbfmin -riscv-v-vector-bits-max=128 -verify-machineinstrs | FileCheck %s -check-prefixes=CHECK,VLS,CHECK32
; RUN: llc < %s -mtriple=riscv64 -mattr=+m,+v,+zvfhmin,+zvfbfmin -riscv-v-vector-bits-max=128 -verify-machineinstrs | FileCheck %s -check-prefixes=CHECK,VLS,CHECK64
; RUN: llc < %s -mtriple=riscv32 -mattr=+m,+v,+zvfh,+zvfbfmin -riscv-v-vector-bits-max=128 -verify-machineinstrs | FileCheck %s -check-prefixes=CHECK,VLS,CHECK32
; RUN: llc < %s -mtriple=riscv64 -mattr=+m,+v,+zvfh,+zvfbfmin -riscv-v-vector-bits-max=128 -verify-machineinstrs | FileCheck %s -check-prefixes=CHECK,VLS,CHECK64

define void @extract_v2i8_v4i8_0(ptr %x, ptr %y) {
; CHECK-LABEL: extract_v2i8_v4i8_0:
; CHECK:       # %bb.0:
; CHECK-NEXT:    lh a0, 0(a0)
; CHECK-NEXT:    sh a0, 0(a1)
; CHECK-NEXT:    ret
  %a = load <4 x i8>, ptr %x
  %c = call <2 x i8> @llvm.vector.extract.v2i8.v4i8(<4 x i8> %a, i64 0)
  store <2 x i8> %c, ptr %y
  ret void
}

define void @extract_v2i8_v4i8_2(ptr %x, ptr %y) {
; CHECK-LABEL: extract_v2i8_v4i8_2:
; CHECK:       # %bb.0:
; CHECK-NEXT:    lh a0, 2(a0)
; CHECK-NEXT:    sh a0, 0(a1)
; CHECK-NEXT:    ret
  %a = load <4 x i8>, ptr %x
  %c = call <2 x i8> @llvm.vector.extract.v2i8.v4i8(<4 x i8> %a, i64 2)
  store <2 x i8> %c, ptr %y
  ret void
}

define void @extract_v2i8_v8i8_0(ptr %x, ptr %y) {
; CHECK-LABEL: extract_v2i8_v8i8_0:
; CHECK:       # %bb.0:
; CHECK-NEXT:    lh a0, 0(a0)
; CHECK-NEXT:    sh a0, 0(a1)
; CHECK-NEXT:    ret
  %a = load <8 x i8>, ptr %x
  %c = call <2 x i8> @llvm.vector.extract.v2i8.v8i8(<8 x i8> %a, i64 0)
  store <2 x i8> %c, ptr %y
  ret void
}

define void @extract_v2i8_v8i8_6(ptr %x, ptr %y) {
; CHECK-LABEL: extract_v2i8_v8i8_6:
; CHECK:       # %bb.0:
; CHECK-NEXT:    lh a0, 6(a0)
; CHECK-NEXT:    sh a0, 0(a1)
; CHECK-NEXT:    ret
  %a = load <8 x i8>, ptr %x
  %c = call <2 x i8> @llvm.vector.extract.v2i8.v8i8(<8 x i8> %a, i64 6)
  store <2 x i8> %c, ptr %y
  ret void
}

define void @extract_v1i32_v8i32_4(ptr %x, ptr %y) {
; CHECK-LABEL: extract_v1i32_v8i32_4:
; CHECK:       # %bb.0:
; CHECK-NEXT:    lw a0, 16(a0)
; CHECK-NEXT:    sw a0, 0(a1)
; CHECK-NEXT:    ret
  %a = load <8 x i32>, ptr %x
  %c = call <1 x i32> @llvm.vector.extract.v1i32.v8i32(<8 x i32> %a, i64 4)
  store <1 x i32> %c, ptr %y
  ret void
}

define void @extract_v1i32_v8i32_5(ptr %x, ptr %y) {
; CHECK-LABEL: extract_v1i32_v8i32_5:
; CHECK:       # %bb.0:
; CHECK-NEXT:    lw a0, 20(a0)
; CHECK-NEXT:    sw a0, 0(a1)
; CHECK-NEXT:    ret
  %a = load <8 x i32>, ptr %x
  %c = call <1 x i32> @llvm.vector.extract.v1i32.v8i32(<8 x i32> %a, i64 5)
  store <1 x i32> %c, ptr %y
  ret void
}

define void @extract_v2i32_v8i32_0(ptr %x, ptr %y) {
; CHECK32-LABEL: extract_v2i32_v8i32_0:
; CHECK32:       # %bb.0:
; CHECK32-NEXT:    vsetivli zero, 2, e32, mf2, ta, ma
; CHECK32-NEXT:    vle32.v v8, (a0)
; CHECK32-NEXT:    vse32.v v8, (a1)
; CHECK32-NEXT:    ret
;
; CHECK64-LABEL: extract_v2i32_v8i32_0:
; CHECK64:       # %bb.0:
; CHECK64-NEXT:    ld a0, 0(a0)
; CHECK64-NEXT:    sd a0, 0(a1)
; CHECK64-NEXT:    ret
  %a = load <8 x i32>, ptr %x
  %c = call <2 x i32> @llvm.vector.extract.v2i32.v8i32(<8 x i32> %a, i64 0)
  store <2 x i32> %c, ptr %y
  ret void
}

define void @extract_v2i32_v8i32_2(ptr %x, ptr %y) {
; CHECK32-LABEL: extract_v2i32_v8i32_2:
; CHECK32:       # %bb.0:
; CHECK32-NEXT:    addi a0, a0, 8
; CHECK32-NEXT:    vsetivli zero, 2, e32, mf2, ta, ma
; CHECK32-NEXT:    vle32.v v8, (a0)
; CHECK32-NEXT:    vse32.v v8, (a1)
; CHECK32-NEXT:    ret
;
; CHECK64-LABEL: extract_v2i32_v8i32_2:
; CHECK64:       # %bb.0:
; CHECK64-NEXT:    ld a0, 8(a0)
; CHECK64-NEXT:    sd a0, 0(a1)
; CHECK64-NEXT:    ret
  %a = load <8 x i32>, ptr %x
  %c = call <2 x i32> @llvm.vector.extract.v2i32.v8i32(<8 x i32> %a, i64 2)
  store <2 x i32> %c, ptr %y
  ret void
}

define void @extract_v2i32_v8i32_4(ptr %x, ptr %y) {
; CHECK32-LABEL: extract_v2i32_v8i32_4:
; CHECK32:       # %bb.0:
; CHECK32-NEXT:    addi a0, a0, 16
; CHECK32-NEXT:    vsetivli zero, 2, e32, mf2, ta, ma
; CHECK32-NEXT:    vle32.v v8, (a0)
; CHECK32-NEXT:    vse32.v v8, (a1)
; CHECK32-NEXT:    ret
;
; CHECK64-LABEL: extract_v2i32_v8i32_4:
; CHECK64:       # %bb.0:
; CHECK64-NEXT:    ld a0, 16(a0)
; CHECK64-NEXT:    sd a0, 0(a1)
; CHECK64-NEXT:    ret
  %a = load <8 x i32>, ptr %x
  %c = call <2 x i32> @llvm.vector.extract.v2i32.v8i32(<8 x i32> %a, i64 4)
  store <2 x i32> %c, ptr %y
  ret void
}

define void @extract_v2i32_v8i32_6(ptr %x, ptr %y) {
; CHECK32-LABEL: extract_v2i32_v8i32_6:
; CHECK32:       # %bb.0:
; CHECK32-NEXT:    addi a0, a0, 24
; CHECK32-NEXT:    vsetivli zero, 2, e32, mf2, ta, ma
; CHECK32-NEXT:    vle32.v v8, (a0)
; CHECK32-NEXT:    vse32.v v8, (a1)
; CHECK32-NEXT:    ret
;
; CHECK64-LABEL: extract_v2i32_v8i32_6:
; CHECK64:       # %bb.0:
; CHECK64-NEXT:    ld a0, 24(a0)
; CHECK64-NEXT:    sd a0, 0(a1)
; CHECK64-NEXT:    ret
  %a = load <8 x i32>, ptr %x
  %c = call <2 x i32> @llvm.vector.extract.v2i32.v8i32(<8 x i32> %a, i64 6)
  store <2 x i32> %c, ptr %y
  ret void
}

define void @extract_v2i32_nxv16i32_0(<vscale x 16 x i32> %x, ptr %y) {
; CHECK-LABEL: extract_v2i32_nxv16i32_0:
; CHECK:       # %bb.0:
; CHECK-NEXT:    vsetivli zero, 2, e32, mf2, ta, ma
; CHECK-NEXT:    vse32.v v8, (a0)
; CHECK-NEXT:    ret
  %c = call <2 x i32> @llvm.vector.extract.v2i32.nxv16i32(<vscale x 16 x i32> %x, i64 0)
  store <2 x i32> %c, ptr %y
  ret void
}


define void @extract_v2i32_nxv16i32_2(<vscale x 16 x i32> %x, ptr %y) {
; CHECK-LABEL: extract_v2i32_nxv16i32_2:
; CHECK:       # %bb.0:
; CHECK-NEXT:    vsetivli zero, 2, e32, m1, ta, ma
; CHECK-NEXT:    vslidedown.vi v8, v8, 2
; CHECK-NEXT:    vsetivli zero, 2, e32, mf2, ta, ma
; CHECK-NEXT:    vse32.v v8, (a0)
; CHECK-NEXT:    ret
  %c = call <2 x i32> @llvm.vector.extract.v2i32.nxv16i32(<vscale x 16 x i32> %x, i64 2)
  store <2 x i32> %c, ptr %y
  ret void
}

define void @extract_v2i32_nxv16i32_4(<vscale x 16 x i32> %x, ptr %y) {
; VLA-LABEL: extract_v2i32_nxv16i32_4:
; VLA:       # %bb.0:
; VLA-NEXT:    vsetivli zero, 2, e32, m2, ta, ma
; VLA-NEXT:    vslidedown.vi v8, v8, 4
; VLA-NEXT:    vsetivli zero, 2, e32, mf2, ta, ma
; VLA-NEXT:    vse32.v v8, (a0)
; VLA-NEXT:    ret
;
; VLS-LABEL: extract_v2i32_nxv16i32_4:
; VLS:       # %bb.0:
; VLS-NEXT:    vsetivli zero, 2, e32, mf2, ta, ma
; VLS-NEXT:    vse32.v v9, (a0)
; VLS-NEXT:    ret
  %c = call <2 x i32> @llvm.vector.extract.v2i32.nxv16i32(<vscale x 16 x i32> %x, i64 4)
  store <2 x i32> %c, ptr %y
  ret void
}

define void @extract_v2i32_nxv16i32_6(<vscale x 16 x i32> %x, ptr %y) {
; VLA-LABEL: extract_v2i32_nxv16i32_6:
; VLA:       # %bb.0:
; VLA-NEXT:    vsetivli zero, 2, e32, m2, ta, ma
; VLA-NEXT:    vslidedown.vi v8, v8, 6
; VLA-NEXT:    vsetivli zero, 2, e32, mf2, ta, ma
; VLA-NEXT:    vse32.v v8, (a0)
; VLA-NEXT:    ret
;
; VLS-LABEL: extract_v2i32_nxv16i32_6:
; VLS:       # %bb.0:
; VLS-NEXT:    vsetivli zero, 2, e32, m1, ta, ma
; VLS-NEXT:    vslidedown.vi v8, v9, 2
; VLS-NEXT:    vsetivli zero, 2, e32, mf2, ta, ma
; VLS-NEXT:    vse32.v v8, (a0)
; VLS-NEXT:    ret
  %c = call <2 x i32> @llvm.vector.extract.v2i32.nxv16i32(<vscale x 16 x i32> %x, i64 6)
  store <2 x i32> %c, ptr %y
  ret void
}

define void @extract_v2i32_nxv16i32_8(<vscale x 16 x i32> %x, ptr %y) {
; VLA-LABEL: extract_v2i32_nxv16i32_8:
; VLA:       # %bb.0:
; VLA-NEXT:    vsetivli zero, 2, e32, m4, ta, ma
; VLA-NEXT:    vslidedown.vi v8, v8, 8
; VLA-NEXT:    vsetivli zero, 2, e32, mf2, ta, ma
; VLA-NEXT:    vse32.v v8, (a0)
; VLA-NEXT:    ret
;
; VLS-LABEL: extract_v2i32_nxv16i32_8:
; VLS:       # %bb.0:
; VLS-NEXT:    vsetivli zero, 2, e32, mf2, ta, ma
; VLS-NEXT:    vse32.v v10, (a0)
; VLS-NEXT:    ret
  %c = call <2 x i32> @llvm.vector.extract.v2i32.nxv16i32(<vscale x 16 x i32> %x, i64 8)
  store <2 x i32> %c, ptr %y
  ret void
}

define void @extract_v2i8_nxv2i8_0(<vscale x 2 x i8> %x, ptr %y) {
; CHECK-LABEL: extract_v2i8_nxv2i8_0:
; CHECK:       # %bb.0:
; CHECK-NEXT:    vsetivli zero, 2, e8, mf8, ta, ma
; CHECK-NEXT:    vse8.v v8, (a0)
; CHECK-NEXT:    ret
  %c = call <2 x i8> @llvm.vector.extract.v2i8.nxv2i8(<vscale x 2 x i8> %x, i64 0)
  store <2 x i8> %c, ptr %y
  ret void
}

define void @extract_v2i8_nxv2i8_2(<vscale x 2 x i8> %x, ptr %y) {
; CHECK-LABEL: extract_v2i8_nxv2i8_2:
; CHECK:       # %bb.0:
; CHECK-NEXT:    vsetivli zero, 2, e8, mf4, ta, ma
; CHECK-NEXT:    vslidedown.vi v8, v8, 2
; CHECK-NEXT:    vsetivli zero, 2, e8, mf8, ta, ma
; CHECK-NEXT:    vse8.v v8, (a0)
; CHECK-NEXT:    ret
  %c = call <2 x i8> @llvm.vector.extract.v2i8.nxv2i8(<vscale x 2 x i8> %x, i64 2)
  store <2 x i8> %c, ptr %y
  ret void
}

define void @extract_v2i8_nxv2i8_4(<vscale x 2 x i8> %x, ptr %y) {
; CHECK-LABEL: extract_v2i8_nxv2i8_4:
; CHECK:       # %bb.0:
; CHECK-NEXT:    vsetivli zero, 2, e8, mf4, ta, ma
; CHECK-NEXT:    vslidedown.vi v8, v8, 4
; CHECK-NEXT:    vsetivli zero, 2, e8, mf8, ta, ma
; CHECK-NEXT:    vse8.v v8, (a0)
; CHECK-NEXT:    ret
  %c = call <2 x i8> @llvm.vector.extract.v2i8.nxv2i8(<vscale x 2 x i8> %x, i64 4)
  store <2 x i8> %c, ptr %y
  ret void
}

define void @extract_v2i8_nxv2i8_6(<vscale x 2 x i8> %x, ptr %y) {
; CHECK-LABEL: extract_v2i8_nxv2i8_6:
; CHECK:       # %bb.0:
; CHECK-NEXT:    vsetivli zero, 2, e8, mf4, ta, ma
; CHECK-NEXT:    vslidedown.vi v8, v8, 6
; CHECK-NEXT:    vsetivli zero, 2, e8, mf8, ta, ma
; CHECK-NEXT:    vse8.v v8, (a0)
; CHECK-NEXT:    ret
  %c = call <2 x i8> @llvm.vector.extract.v2i8.nxv2i8(<vscale x 2 x i8> %x, i64 6)
  store <2 x i8> %c, ptr %y
  ret void
}

define void @extract_v8i32_nxv16i32_8(<vscale x 16 x i32> %x, ptr %y) {
; VLA-LABEL: extract_v8i32_nxv16i32_8:
; VLA:       # %bb.0:
; VLA-NEXT:    vsetivli zero, 8, e32, m4, ta, ma
; VLA-NEXT:    vslidedown.vi v8, v8, 8
; VLA-NEXT:    vsetivli zero, 8, e32, m2, ta, ma
; VLA-NEXT:    vse32.v v8, (a0)
; VLA-NEXT:    ret
;
; VLS-LABEL: extract_v8i32_nxv16i32_8:
; VLS:       # %bb.0:
; VLS-NEXT:    vs2r.v v10, (a0)
; VLS-NEXT:    ret
  %c = call <8 x i32> @llvm.vector.extract.v8i32.nxv16i32(<vscale x 16 x i32> %x, i64 8)
  store <8 x i32> %c, ptr %y
  ret void
}

define void @extract_v8i1_v64i1_0(ptr %x, ptr %y) {
; CHECK-LABEL: extract_v8i1_v64i1_0:
; CHECK:       # %bb.0:
; CHECK-NEXT:    lbu a0, 0(a0)
; CHECK-NEXT:    sb a0, 0(a1)
; CHECK-NEXT:    ret
  %a = load <64 x i1>, ptr %x
  %c = call <8 x i1> @llvm.vector.extract.v8i1.v64i1(<64 x i1> %a, i64 0)
  store <8 x i1> %c, ptr %y
  ret void
}

define void @extract_v8i1_v64i1_8(ptr %x, ptr %y) {
; CHECK-LABEL: extract_v8i1_v64i1_8:
; CHECK:       # %bb.0:
; CHECK-NEXT:    lbu a0, 1(a0)
; CHECK-NEXT:    sb a0, 0(a1)
; CHECK-NEXT:    ret
  %a = load <64 x i1>, ptr %x
  %c = call <8 x i1> @llvm.vector.extract.v8i1.v64i1(<64 x i1> %a, i64 8)
  store <8 x i1> %c, ptr %y
  ret void
}

define void @extract_v8i1_v64i1_48(ptr %x, ptr %y) {
; CHECK-LABEL: extract_v8i1_v64i1_48:
; CHECK:       # %bb.0:
; CHECK-NEXT:    lbu a0, 6(a0)
; CHECK-NEXT:    sb a0, 0(a1)
; CHECK-NEXT:    ret
  %a = load <64 x i1>, ptr %x
  %c = call <8 x i1> @llvm.vector.extract.v8i1.v64i1(<64 x i1> %a, i64 48)
  store <8 x i1> %c, ptr %y
  ret void
}

define void @extract_v8i1_nxv2i1_0(<vscale x 2 x i1> %x, ptr %y) {
; CHECK-LABEL: extract_v8i1_nxv2i1_0:
; CHECK:       # %bb.0:
; CHECK-NEXT:    vsetivli zero, 8, e8, mf2, ta, ma
; CHECK-NEXT:    vsm.v v0, (a0)
; CHECK-NEXT:    ret
  %c = call <8 x i1> @llvm.vector.extract.v8i1.nxv2i1(<vscale x 2 x i1> %x, i64 0)
  store <8 x i1> %c, ptr %y
  ret void
}

define void @extract_v8i1_nxv64i1_0(<vscale x 64 x i1> %x, ptr %y) {
; CHECK-LABEL: extract_v8i1_nxv64i1_0:
; CHECK:       # %bb.0:
; CHECK-NEXT:    vsetivli zero, 8, e8, mf2, ta, ma
; CHECK-NEXT:    vsm.v v0, (a0)
; CHECK-NEXT:    ret
  %c = call <8 x i1> @llvm.vector.extract.v8i1.nxv64i1(<vscale x 64 x i1> %x, i64 0)
  store <8 x i1> %c, ptr %y
  ret void
}

define void @extract_v8i1_nxv64i1_8(<vscale x 64 x i1> %x, ptr %y) {
; CHECK-LABEL: extract_v8i1_nxv64i1_8:
; CHECK:       # %bb.0:
; CHECK-NEXT:    vsetivli zero, 1, e8, m1, ta, ma
; CHECK-NEXT:    vslidedown.vi v8, v0, 1
; CHECK-NEXT:    vsetivli zero, 8, e8, mf2, ta, ma
; CHECK-NEXT:    vsm.v v8, (a0)
; CHECK-NEXT:    ret
  %c = call <8 x i1> @llvm.vector.extract.v8i1.nxv64i1(<vscale x 64 x i1> %x, i64 8)
  store <8 x i1> %c, ptr %y
  ret void
}

define void @extract_v8i1_nxv64i1_48(<vscale x 64 x i1> %x, ptr %y) {
; CHECK-LABEL: extract_v8i1_nxv64i1_48:
; CHECK:       # %bb.0:
; CHECK-NEXT:    vsetivli zero, 1, e8, m1, ta, ma
; CHECK-NEXT:    vslidedown.vi v8, v0, 6
; CHECK-NEXT:    vsetivli zero, 8, e8, mf2, ta, ma
; CHECK-NEXT:    vsm.v v8, (a0)
; CHECK-NEXT:    ret
  %c = call <8 x i1> @llvm.vector.extract.v8i1.nxv64i1(<vscale x 64 x i1> %x, i64 48)
  store <8 x i1> %c, ptr %y
  ret void
}

define void @extract_v8i1_nxv64i1_128(<vscale x 64 x i1> %x, ptr %y) {
; CHECK-LABEL: extract_v8i1_nxv64i1_128:
; CHECK:       # %bb.0:
; CHECK-NEXT:    vsetivli zero, 1, e8, m1, ta, ma
; CHECK-NEXT:    vslidedown.vi v8, v0, 16
; CHECK-NEXT:    vsetivli zero, 8, e8, mf2, ta, ma
; CHECK-NEXT:    vsm.v v8, (a0)
; CHECK-NEXT:    ret
  %c = call <8 x i1> @llvm.vector.extract.v8i1.nxv64i1(<vscale x 64 x i1> %x, i64 128)
  store <8 x i1> %c, ptr %y
  ret void
}

define void @extract_v8i1_nxv64i1_192(<vscale x 64 x i1> %x, ptr %y) {
; CHECK-LABEL: extract_v8i1_nxv64i1_192:
; CHECK:       # %bb.0:
; CHECK-NEXT:    vsetivli zero, 1, e8, m1, ta, ma
; CHECK-NEXT:    vslidedown.vi v8, v0, 24
; CHECK-NEXT:    vsetivli zero, 8, e8, mf2, ta, ma
; CHECK-NEXT:    vsm.v v8, (a0)
; CHECK-NEXT:    ret
  %c = call <8 x i1> @llvm.vector.extract.v8i1.nxv64i1(<vscale x 64 x i1> %x, i64 192)
  store <8 x i1> %c, ptr %y
  ret void
}

define void @extract_v2i1_v64i1_0(ptr %x, ptr %y) {
; VLA-LABEL: extract_v2i1_v64i1_0:
; VLA:       # %bb.0:
; VLA-NEXT:    li a2, 64
; VLA-NEXT:    vsetvli zero, a2, e8, m4, ta, ma
; VLA-NEXT:    vlm.v v0, (a0)
; VLA-NEXT:    vsetivli zero, 2, e8, mf8, ta, ma
; VLA-NEXT:    vmv.v.i v8, 0
; VLA-NEXT:    vmerge.vim v8, v8, 1, v0
; VLA-NEXT:    vsetivli zero, 8, e8, mf2, ta, ma
; VLA-NEXT:    vmv.v.i v9, 0
; VLA-NEXT:    vsetivli zero, 2, e8, mf2, tu, ma
; VLA-NEXT:    vmv.v.v v9, v8
; VLA-NEXT:    vsetivli zero, 8, e8, mf2, ta, ma
; VLA-NEXT:    vmsne.vi v8, v9, 0
; VLA-NEXT:    vsm.v v8, (a1)
; VLA-NEXT:    ret
;
; VLS-LABEL: extract_v2i1_v64i1_0:
; VLS:       # %bb.0:
; VLS-NEXT:    vsetvli a2, zero, e8, m4, ta, ma
; VLS-NEXT:    vlm.v v0, (a0)
; VLS-NEXT:    vsetivli zero, 2, e8, mf8, ta, ma
; VLS-NEXT:    vmv.v.i v8, 0
; VLS-NEXT:    vmerge.vim v8, v8, 1, v0
; VLS-NEXT:    vsetivli zero, 8, e8, mf2, ta, ma
; VLS-NEXT:    vmv.v.i v9, 0
; VLS-NEXT:    vsetivli zero, 2, e8, mf2, tu, ma
; VLS-NEXT:    vmv.v.v v9, v8
; VLS-NEXT:    vsetivli zero, 8, e8, mf2, ta, ma
; VLS-NEXT:    vmsne.vi v8, v9, 0
; VLS-NEXT:    vsm.v v8, (a1)
; VLS-NEXT:    ret
  %a = load <64 x i1>, ptr %x
  %c = call <2 x i1> @llvm.vector.extract.v2i1.v64i1(<64 x i1> %a, i64 0)
  store <2 x i1> %c, ptr %y
  ret void
}

define void @extract_v2i1_v64i1_2(ptr %x, ptr %y) {
; VLA-LABEL: extract_v2i1_v64i1_2:
; VLA:       # %bb.0:
; VLA-NEXT:    li a2, 64
; VLA-NEXT:    vsetvli zero, a2, e8, m4, ta, ma
; VLA-NEXT:    vlm.v v0, (a0)
; VLA-NEXT:    vmv.v.i v8, 0
; VLA-NEXT:    vmerge.vim v8, v8, 1, v0
; VLA-NEXT:    vsetivli zero, 2, e8, m1, ta, ma
; VLA-NEXT:    vslidedown.vi v8, v8, 2
; VLA-NEXT:    vsetivli zero, 2, e8, mf8, ta, ma
; VLA-NEXT:    vmsne.vi v0, v8, 0
; VLA-NEXT:    vmv.v.i v8, 0
; VLA-NEXT:    vmerge.vim v8, v8, 1, v0
; VLA-NEXT:    vsetivli zero, 8, e8, mf2, ta, ma
; VLA-NEXT:    vmv.v.i v9, 0
; VLA-NEXT:    vsetivli zero, 2, e8, mf2, tu, ma
; VLA-NEXT:    vmv.v.v v9, v8
; VLA-NEXT:    vsetivli zero, 8, e8, mf2, ta, ma
; VLA-NEXT:    vmsne.vi v8, v9, 0
; VLA-NEXT:    vsm.v v8, (a1)
; VLA-NEXT:    ret
;
; VLS-LABEL: extract_v2i1_v64i1_2:
; VLS:       # %bb.0:
; VLS-NEXT:    vsetvli a2, zero, e8, m4, ta, ma
; VLS-NEXT:    vlm.v v0, (a0)
; VLS-NEXT:    vmv.v.i v8, 0
; VLS-NEXT:    vmerge.vim v8, v8, 1, v0
; VLS-NEXT:    vsetivli zero, 2, e8, m1, ta, ma
; VLS-NEXT:    vslidedown.vi v8, v8, 2
; VLS-NEXT:    vsetivli zero, 2, e8, mf8, ta, ma
; VLS-NEXT:    vmsne.vi v0, v8, 0
; VLS-NEXT:    vmv.v.i v8, 0
; VLS-NEXT:    vmerge.vim v8, v8, 1, v0
; VLS-NEXT:    vsetivli zero, 8, e8, mf2, ta, ma
; VLS-NEXT:    vmv.v.i v9, 0
; VLS-NEXT:    vsetivli zero, 2, e8, mf2, tu, ma
; VLS-NEXT:    vmv.v.v v9, v8
; VLS-NEXT:    vsetivli zero, 8, e8, mf2, ta, ma
; VLS-NEXT:    vmsne.vi v8, v9, 0
; VLS-NEXT:    vsm.v v8, (a1)
; VLS-NEXT:    ret
  %a = load <64 x i1>, ptr %x
  %c = call <2 x i1> @llvm.vector.extract.v2i1.v64i1(<64 x i1> %a, i64 2)
  store <2 x i1> %c, ptr %y
  ret void
}

define void @extract_v2i1_v64i1_42(ptr %x, ptr %y) {
; VLA-LABEL: extract_v2i1_v64i1_42:
; VLA:       # %bb.0:
; VLA-NEXT:    li a2, 64
; VLA-NEXT:    vsetvli zero, a2, e8, m4, ta, ma
; VLA-NEXT:    vlm.v v0, (a0)
; VLA-NEXT:    li a0, 42
; VLA-NEXT:    vmv.v.i v8, 0
; VLA-NEXT:    vmerge.vim v8, v8, 1, v0
; VLA-NEXT:    vsetivli zero, 2, e8, m4, ta, ma
; VLA-NEXT:    vslidedown.vx v8, v8, a0
; VLA-NEXT:    vsetivli zero, 2, e8, mf8, ta, ma
; VLA-NEXT:    vmsne.vi v0, v8, 0
; VLA-NEXT:    vmv.v.i v8, 0
; VLA-NEXT:    vmerge.vim v8, v8, 1, v0
; VLA-NEXT:    vsetivli zero, 8, e8, mf2, ta, ma
; VLA-NEXT:    vmv.v.i v9, 0
; VLA-NEXT:    vsetivli zero, 2, e8, mf2, tu, ma
; VLA-NEXT:    vmv.v.v v9, v8
; VLA-NEXT:    vsetivli zero, 8, e8, mf2, ta, ma
; VLA-NEXT:    vmsne.vi v8, v9, 0
; VLA-NEXT:    vsm.v v8, (a1)
; VLA-NEXT:    ret
;
; VLS-LABEL: extract_v2i1_v64i1_42:
; VLS:       # %bb.0:
; VLS-NEXT:    vsetvli a2, zero, e8, m4, ta, ma
; VLS-NEXT:    vlm.v v0, (a0)
; VLS-NEXT:    vmv.v.i v8, 0
; VLS-NEXT:    vmerge.vim v8, v8, 1, v0
; VLS-NEXT:    vsetivli zero, 2, e8, m1, ta, ma
; VLS-NEXT:    vslidedown.vi v8, v10, 10
; VLS-NEXT:    vsetivli zero, 2, e8, mf8, ta, ma
; VLS-NEXT:    vmsne.vi v0, v8, 0
; VLS-NEXT:    vmv.v.i v8, 0
; VLS-NEXT:    vmerge.vim v8, v8, 1, v0
; VLS-NEXT:    vsetivli zero, 8, e8, mf2, ta, ma
; VLS-NEXT:    vmv.v.i v9, 0
; VLS-NEXT:    vsetivli zero, 2, e8, mf2, tu, ma
; VLS-NEXT:    vmv.v.v v9, v8
; VLS-NEXT:    vsetivli zero, 8, e8, mf2, ta, ma
; VLS-NEXT:    vmsne.vi v8, v9, 0
; VLS-NEXT:    vsm.v v8, (a1)
; VLS-NEXT:    ret
  %a = load <64 x i1>, ptr %x
  %c = call <2 x i1> @llvm.vector.extract.v2i1.v64i1(<64 x i1> %a, i64 42)
  store <2 x i1> %c, ptr %y
  ret void
}

define void @extract_v2i1_nxv2i1_0(<vscale x 2 x i1> %x, ptr %y) {
; CHECK-LABEL: extract_v2i1_nxv2i1_0:
; CHECK:       # %bb.0:
; CHECK-NEXT:    vsetivli zero, 2, e8, mf8, ta, ma
; CHECK-NEXT:    vmv.v.i v8, 0
; CHECK-NEXT:    vmerge.vim v8, v8, 1, v0
; CHECK-NEXT:    vsetivli zero, 8, e8, mf2, ta, ma
; CHECK-NEXT:    vmv.v.i v9, 0
; CHECK-NEXT:    vsetivli zero, 2, e8, mf2, tu, ma
; CHECK-NEXT:    vmv.v.v v9, v8
; CHECK-NEXT:    vsetivli zero, 8, e8, mf2, ta, ma
; CHECK-NEXT:    vmsne.vi v8, v9, 0
; CHECK-NEXT:    vsm.v v8, (a0)
; CHECK-NEXT:    ret
  %c = call <2 x i1> @llvm.vector.extract.v2i1.nxv2i1(<vscale x 2 x i1> %x, i64 0)
  store <2 x i1> %c, ptr %y
  ret void
}

define void @extract_v2i1_nxv2i1_2(<vscale x 2 x i1> %x, ptr %y) {
; VLA-LABEL: extract_v2i1_nxv2i1_2:
; VLA:       # %bb.0:
; VLA-NEXT:    vsetvli a1, zero, e8, mf4, ta, ma
; VLA-NEXT:    vmv.v.i v8, 0
; VLA-NEXT:    vmerge.vim v8, v8, 1, v0
; VLA-NEXT:    vsetivli zero, 2, e8, mf4, ta, ma
; VLA-NEXT:    vslidedown.vi v8, v8, 2
; VLA-NEXT:    vsetivli zero, 2, e8, mf8, ta, ma
; VLA-NEXT:    vmsne.vi v0, v8, 0
; VLA-NEXT:    vmv.v.i v8, 0
; VLA-NEXT:    vmerge.vim v8, v8, 1, v0
; VLA-NEXT:    vsetivli zero, 8, e8, mf2, ta, ma
; VLA-NEXT:    vmv.v.i v9, 0
; VLA-NEXT:    vsetivli zero, 2, e8, mf2, tu, ma
; VLA-NEXT:    vmv.v.v v9, v8
; VLA-NEXT:    vsetivli zero, 8, e8, mf2, ta, ma
; VLA-NEXT:    vmsne.vi v8, v9, 0
; VLA-NEXT:    vsm.v v8, (a0)
; VLA-NEXT:    ret
;
; VLS-LABEL: extract_v2i1_nxv2i1_2:
; VLS:       # %bb.0:
; VLS-NEXT:    vsetivli zero, 4, e8, mf4, ta, ma
; VLS-NEXT:    vmv.v.i v8, 0
; VLS-NEXT:    vmerge.vim v8, v8, 1, v0
; VLS-NEXT:    vsetivli zero, 2, e8, mf4, ta, ma
; VLS-NEXT:    vslidedown.vi v8, v8, 2
; VLS-NEXT:    vsetivli zero, 2, e8, mf8, ta, ma
; VLS-NEXT:    vmsne.vi v0, v8, 0
; VLS-NEXT:    vmv.v.i v8, 0
; VLS-NEXT:    vmerge.vim v8, v8, 1, v0
; VLS-NEXT:    vsetivli zero, 8, e8, mf2, ta, ma
; VLS-NEXT:    vmv.v.i v9, 0
; VLS-NEXT:    vsetivli zero, 2, e8, mf2, tu, ma
; VLS-NEXT:    vmv.v.v v9, v8
; VLS-NEXT:    vsetivli zero, 8, e8, mf2, ta, ma
; VLS-NEXT:    vmsne.vi v8, v9, 0
; VLS-NEXT:    vsm.v v8, (a0)
; VLS-NEXT:    ret
  %c = call <2 x i1> @llvm.vector.extract.v2i1.nxv2i1(<vscale x 2 x i1> %x, i64 2)
  store <2 x i1> %c, ptr %y
  ret void
}

define void @extract_v2i1_nxv64i1_0(<vscale x 64 x i1> %x, ptr %y) {
; CHECK-LABEL: extract_v2i1_nxv64i1_0:
; CHECK:       # %bb.0:
; CHECK-NEXT:    vsetivli zero, 2, e8, mf8, ta, ma
; CHECK-NEXT:    vmv.v.i v8, 0
; CHECK-NEXT:    vmerge.vim v8, v8, 1, v0
; CHECK-NEXT:    vsetivli zero, 8, e8, mf2, ta, ma
; CHECK-NEXT:    vmv.v.i v9, 0
; CHECK-NEXT:    vsetivli zero, 2, e8, mf2, tu, ma
; CHECK-NEXT:    vmv.v.v v9, v8
; CHECK-NEXT:    vsetivli zero, 8, e8, mf2, ta, ma
; CHECK-NEXT:    vmsne.vi v8, v9, 0
; CHECK-NEXT:    vsm.v v8, (a0)
; CHECK-NEXT:    ret
  %c = call <2 x i1> @llvm.vector.extract.v2i1.nxv64i1(<vscale x 64 x i1> %x, i64 0)
  store <2 x i1> %c, ptr %y
  ret void
}

define void @extract_v2i1_nxv64i1_2(<vscale x 64 x i1> %x, ptr %y) {
; CHECK-LABEL: extract_v2i1_nxv64i1_2:
; CHECK:       # %bb.0:
; CHECK-NEXT:    vsetvli a1, zero, e8, m8, ta, ma
; CHECK-NEXT:    vmv.v.i v8, 0
; CHECK-NEXT:    vmerge.vim v8, v8, 1, v0
; CHECK-NEXT:    vsetivli zero, 2, e8, m1, ta, ma
; CHECK-NEXT:    vslidedown.vi v8, v8, 2
; CHECK-NEXT:    vsetivli zero, 2, e8, mf8, ta, ma
; CHECK-NEXT:    vmsne.vi v0, v8, 0
; CHECK-NEXT:    vmv.v.i v8, 0
; CHECK-NEXT:    vmerge.vim v8, v8, 1, v0
; CHECK-NEXT:    vsetivli zero, 8, e8, mf2, ta, ma
; CHECK-NEXT:    vmv.v.i v9, 0
; CHECK-NEXT:    vsetivli zero, 2, e8, mf2, tu, ma
; CHECK-NEXT:    vmv.v.v v9, v8
; CHECK-NEXT:    vsetivli zero, 8, e8, mf2, ta, ma
; CHECK-NEXT:    vmsne.vi v8, v9, 0
; CHECK-NEXT:    vsm.v v8, (a0)
; CHECK-NEXT:    ret
  %c = call <2 x i1> @llvm.vector.extract.v2i1.nxv64i1(<vscale x 64 x i1> %x, i64 2)
  store <2 x i1> %c, ptr %y
  ret void
}

define void @extract_v2i1_nxv64i1_42(<vscale x 64 x i1> %x, ptr %y) {
; VLA-LABEL: extract_v2i1_nxv64i1_42:
; VLA:       # %bb.0:
; VLA-NEXT:    vsetvli a1, zero, e8, m8, ta, ma
; VLA-NEXT:    vmv.v.i v8, 0
; VLA-NEXT:    li a1, 42
; VLA-NEXT:    vmerge.vim v8, v8, 1, v0
; VLA-NEXT:    vsetivli zero, 2, e8, m4, ta, ma
; VLA-NEXT:    vslidedown.vx v8, v8, a1
; VLA-NEXT:    vsetivli zero, 2, e8, mf8, ta, ma
; VLA-NEXT:    vmsne.vi v0, v8, 0
; VLA-NEXT:    vmv.v.i v8, 0
; VLA-NEXT:    vmerge.vim v8, v8, 1, v0
; VLA-NEXT:    vsetivli zero, 8, e8, mf2, ta, ma
; VLA-NEXT:    vmv.v.i v9, 0
; VLA-NEXT:    vsetivli zero, 2, e8, mf2, tu, ma
; VLA-NEXT:    vmv.v.v v9, v8
; VLA-NEXT:    vsetivli zero, 8, e8, mf2, ta, ma
; VLA-NEXT:    vmsne.vi v8, v9, 0
; VLA-NEXT:    vsm.v v8, (a0)
; VLA-NEXT:    ret
;
; VLS-LABEL: extract_v2i1_nxv64i1_42:
; VLS:       # %bb.0:
; VLS-NEXT:    vsetvli a1, zero, e8, m8, ta, ma
; VLS-NEXT:    vmv.v.i v8, 0
; VLS-NEXT:    vmerge.vim v8, v8, 1, v0
; VLS-NEXT:    vsetivli zero, 2, e8, m1, ta, ma
; VLS-NEXT:    vslidedown.vi v8, v10, 10
; VLS-NEXT:    vsetivli zero, 2, e8, mf8, ta, ma
; VLS-NEXT:    vmsne.vi v0, v8, 0
; VLS-NEXT:    vmv.v.i v8, 0
; VLS-NEXT:    vmerge.vim v8, v8, 1, v0
; VLS-NEXT:    vsetivli zero, 8, e8, mf2, ta, ma
; VLS-NEXT:    vmv.v.i v9, 0
; VLS-NEXT:    vsetivli zero, 2, e8, mf2, tu, ma
; VLS-NEXT:    vmv.v.v v9, v8
; VLS-NEXT:    vsetivli zero, 8, e8, mf2, ta, ma
; VLS-NEXT:    vmsne.vi v8, v9, 0
; VLS-NEXT:    vsm.v v8, (a0)
; VLS-NEXT:    ret
  %c = call <2 x i1> @llvm.vector.extract.v2i1.nxv64i1(<vscale x 64 x i1> %x, i64 42)
  store <2 x i1> %c, ptr %y
  ret void
}

define void @extract_v2i1_nxv32i1_26(<vscale x 32 x i1> %x, ptr %y) {
; VLA-LABEL: extract_v2i1_nxv32i1_26:
; VLA:       # %bb.0:
; VLA-NEXT:    vsetvli a1, zero, e8, m4, ta, ma
; VLA-NEXT:    vmv.v.i v8, 0
; VLA-NEXT:    vmerge.vim v8, v8, 1, v0
; VLA-NEXT:    vsetivli zero, 2, e8, m2, ta, ma
; VLA-NEXT:    vslidedown.vi v8, v8, 26
; VLA-NEXT:    vsetivli zero, 2, e8, mf8, ta, ma
; VLA-NEXT:    vmsne.vi v0, v8, 0
; VLA-NEXT:    vmv.v.i v8, 0
; VLA-NEXT:    vmerge.vim v8, v8, 1, v0
; VLA-NEXT:    vsetivli zero, 8, e8, mf2, ta, ma
; VLA-NEXT:    vmv.v.i v9, 0
; VLA-NEXT:    vsetivli zero, 2, e8, mf2, tu, ma
; VLA-NEXT:    vmv.v.v v9, v8
; VLA-NEXT:    vsetivli zero, 8, e8, mf2, ta, ma
; VLA-NEXT:    vmsne.vi v8, v9, 0
; VLA-NEXT:    vsm.v v8, (a0)
; VLA-NEXT:    ret
;
; VLS-LABEL: extract_v2i1_nxv32i1_26:
; VLS:       # %bb.0:
; VLS-NEXT:    vsetvli a1, zero, e8, m4, ta, ma
; VLS-NEXT:    vmv.v.i v8, 0
; VLS-NEXT:    vmerge.vim v8, v8, 1, v0
; VLS-NEXT:    vsetivli zero, 2, e8, m1, ta, ma
; VLS-NEXT:    vslidedown.vi v8, v9, 10
; VLS-NEXT:    vsetivli zero, 2, e8, mf8, ta, ma
; VLS-NEXT:    vmsne.vi v0, v8, 0
; VLS-NEXT:    vmv.v.i v8, 0
; VLS-NEXT:    vmerge.vim v8, v8, 1, v0
; VLS-NEXT:    vsetivli zero, 8, e8, mf2, ta, ma
; VLS-NEXT:    vmv.v.i v9, 0
; VLS-NEXT:    vsetivli zero, 2, e8, mf2, tu, ma
; VLS-NEXT:    vmv.v.v v9, v8
; VLS-NEXT:    vsetivli zero, 8, e8, mf2, ta, ma
; VLS-NEXT:    vmsne.vi v8, v9, 0
; VLS-NEXT:    vsm.v v8, (a0)
; VLS-NEXT:    ret
  %c = call <2 x i1> @llvm.vector.extract.v2i1.nxv32i1(<vscale x 32 x i1> %x, i64 26)
  store <2 x i1> %c, ptr %y
  ret void
}

define void @extract_v8i1_nxv32i1_16(<vscale x 32 x i1> %x, ptr %y) {
; CHECK-LABEL: extract_v8i1_nxv32i1_16:
; CHECK:       # %bb.0:
; CHECK-NEXT:    vsetivli zero, 8, e8, mf2, ta, ma
; CHECK-NEXT:    vslidedown.vi v8, v0, 2
; CHECK-NEXT:    vsm.v v8, (a0)
; CHECK-NEXT:    ret
  %c = call <8 x i1> @llvm.vector.extract.v8i1.nxv32i1(<vscale x 32 x i1> %x, i64 16)
  store <8 x i1> %c, ptr %y
  ret void
}

define <1 x i64> @extract_v1i64_v2i64_1(<2 x i64> %x) {
; CHECK-LABEL: extract_v1i64_v2i64_1:
; CHECK:       # %bb.0:
; CHECK-NEXT:    vsetivli zero, 1, e64, m1, ta, ma
; CHECK-NEXT:    vslidedown.vi v8, v8, 1
; CHECK-NEXT:    ret
  %v = call <1 x i64> @llvm.vector.extract.v1i64.v2i64(<2 x i64> %x, i64 1)
  ret <1 x i64> %v
}

define void @extract_v2bf16_v4bf16_0(ptr %x, ptr %y) {
; CHECK-LABEL: extract_v2bf16_v4bf16_0:
; CHECK:       # %bb.0:
; CHECK-NEXT:    lw a0, 0(a0)
; CHECK-NEXT:    sw a0, 0(a1)
; CHECK-NEXT:    ret
  %a = load <4 x bfloat>, ptr %x
  %c = call <2 x bfloat> @llvm.vector.extract.v2bf16.v4bf16(<4 x bfloat> %a, i64 0)
  store <2 x bfloat> %c, ptr %y
  ret void
}

define void @extract_v2bf16_v4bf16_2(ptr %x, ptr %y) {
; CHECK-LABEL: extract_v2bf16_v4bf16_2:
; CHECK:       # %bb.0:
; CHECK-NEXT:    lw a0, 4(a0)
; CHECK-NEXT:    sw a0, 0(a1)
; CHECK-NEXT:    ret
  %a = load <4 x bfloat>, ptr %x
  %c = call <2 x bfloat> @llvm.vector.extract.v2bf16.v4bf16(<4 x bfloat> %a, i64 2)
  store <2 x bfloat> %c, ptr %y
  ret void
}

define void @extract_v2f16_v4f16_0(ptr %x, ptr %y) {
; CHECK-LABEL: extract_v2f16_v4f16_0:
; CHECK:       # %bb.0:
; CHECK-NEXT:    lw a0, 0(a0)
; CHECK-NEXT:    sw a0, 0(a1)
; CHECK-NEXT:    ret
  %a = load <4 x half>, ptr %x
  %c = call <2 x half> @llvm.vector.extract.v2f16.v4f16(<4 x half> %a, i64 0)
  store <2 x half> %c, ptr %y
  ret void
}

define void @extract_v2f16_v4f16_2(ptr %x, ptr %y) {
; CHECK-LABEL: extract_v2f16_v4f16_2:
; CHECK:       # %bb.0:
; CHECK-NEXT:    lw a0, 4(a0)
; CHECK-NEXT:    sw a0, 0(a1)
; CHECK-NEXT:    ret
  %a = load <4 x half>, ptr %x
  %c = call <2 x half> @llvm.vector.extract.v2f16.v4f16(<4 x half> %a, i64 2)
  store <2 x half> %c, ptr %y
  ret void
}

declare <2 x i1> @llvm.vector.extract.v2i1.v64i1(<64 x i1> %vec, i64 %idx)
declare <8 x i1> @llvm.vector.extract.v8i1.v64i1(<64 x i1> %vec, i64 %idx)

declare <2 x i1> @llvm.vector.extract.v2i1.nxv2i1(<vscale x 2 x i1> %vec, i64 %idx)
declare <8 x i1> @llvm.vector.extract.v8i1.nxv2i1(<vscale x 2 x i1> %vec, i64 %idx)

declare <2 x i1> @llvm.vector.extract.v2i1.nxv32i1(<vscale x 32 x i1> %vec, i64 %idx)
declare <8 x i1> @llvm.vector.extract.v8i1.nxv32i1(<vscale x 32 x i1> %vec, i64 %idx)

declare <2 x i1> @llvm.vector.extract.v2i1.nxv64i1(<vscale x 64 x i1> %vec, i64 %idx)
declare <8 x i1> @llvm.vector.extract.v8i1.nxv64i1(<vscale x 64 x i1> %vec, i64 %idx)

declare <2 x i8> @llvm.vector.extract.v2i8.v4i8(<4 x i8> %vec, i64 %idx)
declare <2 x i8> @llvm.vector.extract.v2i8.v8i8(<8 x i8> %vec, i64 %idx)

declare <1 x i32> @llvm.vector.extract.v1i32.v8i32(<8 x i32> %vec, i64 %idx)
declare <2 x i32> @llvm.vector.extract.v2i32.v8i32(<8 x i32> %vec, i64 %idx)

declare <2 x i8> @llvm.vector.extract.v2i8.nxv2i8(<vscale x 2 x i8> %vec, i64 %idx)

declare <2 x i32> @llvm.vector.extract.v2i32.nxv16i32(<vscale x 16 x i32> %vec, i64 %idx)
declare <8 x i32> @llvm.vector.extract.v8i32.nxv16i32(<vscale x 16 x i32> %vec, i64 %idx)
