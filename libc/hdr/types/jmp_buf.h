//===-- Definition of jmp_buf.h -------------------------------------------===//
//
// Part of the LLVM Project, under the Apahce License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#ifndef LLVM_LIBC_HDR_TYPES_JMP_BUF_H
#define LLVM_LIBC_HDR_TYPES_JMP_BUF_H

#ifdef LIBC_FULL_BUILD

#include "include/llvm-libc-types/jmp_buf.h"

#else // overlay mode

#include <setjmp.h>

#endif // LLVM_LIBC_FULL_BUILD

#endif // LLVM_LIBC_HDR_TYPES_JMP_BUF_H
