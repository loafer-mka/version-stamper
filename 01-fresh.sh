#!/bin/bash

# +--------------------------------------------------------------------+
# | This Source Code Form is subject to the terms of the Mozilla       |
# | Public License, v. 2.0. If a copy of the MPL was not distributed   |
# | with this file, You can obtain one at http://mozilla.org/MPL/2.0/. |
# +--------------------------------------------------------------------+
#        email: Andrey Makarov <mka-at-mailru@mail.ru>
# Project home: https://github.com/loafer-mka/version-stamper.git
#
#               Copyright (c) Andrey Makarov 2023

. "$(dirname "$0")/lib.sh"

pushd "$(dirname "$0")/repos" >/dev/null 2>&1

[ \
  -d "./bare0.git" -a -d "./bare1.git"   -a \
  -d "./fresh"     -a -d "./contrib"     -a \
  -d "./detach-f"  -a -d "./detach-p"    -a \
  -d "./clone-a"   -a -d "./clone-e"     -a \
  -d "./clone-x"   -a -d "./clone-x.git" -a \
  -d "./clone-m"   -a -d "./worktree"       \
] || ../000-init-repos.sh

CLEAN_HOOKS fresh/.git

# check for fresh repo
pushd fresh >/dev/null 2>&1
../../../version-stamper -p | LOAD_A
popd >/dev/null 2>&1
# check for -cd option and fresh repo
../../version-stamper -p -cd fresh | LOAD_B

# PRINT_A_B

[ \
	   "v0.0-0.MASTER" == "${A[VERSION_TEXT]}" \
	-a "v0.0-0.MASTER" == "${B[VERSION_TEXT]}" \
	-a "v" == "${A[VERSION_PREFIX]}"      -a "v" == "${B[VERSION_PREFIX]}" \
	-a "0" == "${A[VERSION_MAJOR]}"       -a "0" == "${B[VERSION_MAJOR]}" \
	-a "0" == "${A[VERSION_MINOR]}"       -a "0" == "${B[VERSION_MINOR]}" \
	-a "0" == "${A[VERSION_BUILD]}"       -a "0" == "${B[VERSION_BUILD]}" \
	-a "MASTER" == "${A[VERSION_BRANCH]}" -a "MASTER" == "${B[VERSION_BRANCH]}" \
	-a "00000000" == "${A[VERSION_ID]}"   -a "00000000" == "${B[VERSION_ID]}" \
	-a "" == "${A[VERSION_DIRTY]}"        -a "" == "${B[VERSION_DIRTY]}" \
	-a "" == "${A[VERSION_LEADER]}"       -a "" == "${B[VERSION_LEADER]}" \
	-a "" == "${A[VERSION_TRAILER]}"      -a "" == "${A[VERSION_TRAILER]}"\
	-a "0000000000000000000000000000000000000000" == "${A[VERSION_SHA_LONG]}" \
	-a "0000000000000000000000000000000000000000" == "${B[VERSION_SHA_LONG]}" \
	-a "${A[VERSION_SHA_LONG]}" == "${B[VERSION_SHA_LONG]}" \
	-a "${A[VERSION_SHA_LONG]:0:${#A[VERSION_SHA_SHORT]}}" == "${A[VERSION_SHA_SHORT]}" \
	-a "" == "${A[VERSION_SUBMOD_NAME]}"  -a "" == "${B[VERSION_SUBMOD_NAME]}" \
	-a "" == "${A[VERSION_SUBMOD_PATH]}"  -a "" == "${B[VERSION_SUBMOD_PATH]}" \
] || DIE 1 "[FAIL]  $0      WRONG DATA"

[ "true" == "$(HOOKS_EXIST fresh/.git)" ] && DIE 1 "[FAIL]  $0      UNWANTED HOOK FOUND FOR fresh"

echo "[ OK ]  $0      empty repository; hooks were not set; -cd option ok"

popd >/dev/null 2>&1
