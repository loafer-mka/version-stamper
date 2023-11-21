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

unset A B
pushd fresh >/dev/null 2>&1
../../../version-stamper -p | LOAD_A | while read L ; do eval $L; done
popd >/dev/null 2>&1
../../version-stamper -p -cd fresh | LOAD_B | while read L ; do eval $L; done

# PRINT_A_B

[ \
	-n "${A[VERSION_TEXT]}" -a -n "${B[VERSION_TEXT]}" -a "${A[VERSION_TEXT]}" == "${B[VERSION_TEXT]}" \
	-a "0000000000000000000000000000000000000000" == "${A[VERSION_SHA_LONG]}" \
	-a "0000000000000000000000000000000000000000" == "${B[VERSION_SHA_LONG]}" \
	-a "00000000" == "${A[VERSION_HEX]}" -a "00000000" == "${B[VERSION_ID]}" \
] || DIE 1 "[FAIL]  $0  WRONG DATA"

[ "true" == "$(HOOKS_EXIST fresh/.git)" ] && DIE 1 "[FAIL]  $0  UNWANTED HOOK FOUND"

echo "[ OK ]  $0"

CLEAN_HOOKS fresh/.git

popd >/dev/null 2>&1
