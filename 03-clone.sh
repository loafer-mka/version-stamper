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

CLEAN_HOOKS contrib/.git
CLEAN_HOOKS clone-m/.git

../../version-stamper --directory contrib -p | LOAD_A
../../version-stamper --directory clone-m -p | LOAD_B

# PRINT_A_B

[ \
	   "v0.0.18-SUBMOD" == "${A[VERSION_TEXT]}" \
	-a "v0.0.18-SUBMOD" == "${B[VERSION_TEXT]}" \
	-a "v" == "${A[VERSION_PREFIX]}"      -a "v" == "${B[VERSION_PREFIX]}" \
	-a "0" == "${A[VERSION_MAJOR]}"       -a "0" == "${B[VERSION_MAJOR]}" \
	-a "0" == "${A[VERSION_MINOR]}"       -a "0" == "${B[VERSION_MINOR]}" \
	-a "18" == "${A[VERSION_BUILD]}"      -a "18" == "${B[VERSION_BUILD]}" \
	-a "SUBMOD" == "${A[VERSION_BRANCH]}" -a "SUBMOD" == "${B[VERSION_BRANCH]}" \
	-a "00000012" == "${A[VERSION_ID]}"   -a "00000012" == "${B[VERSION_ID]}" \
	-a "" == "${A[VERSION_DIRTY]}"        -a "" == "${B[VERSION_DIRTY]}" \
	-a "" == "${A[VERSION_LEADER]}"       -a "" == "${B[VERSION_LEADER]}" \
	-a "" == "${A[VERSION_TRAILER]}"      -a "" == "${A[VERSION_TRAILER]}"\
	-a "0000000000000000000000000000000000000000" != "${A[VERSION_SHA_LONG]}" \
	-a "0000000000000000000000000000000000000000" != "${B[VERSION_SHA_LONG]}" \
	-a "${A[VERSION_SHA_LONG]}" == "${B[VERSION_SHA_LONG]}" \
	-a "${A[VERSION_SHA_SHORT]}" == "${B[VERSION_SHA_SHORT]}" \
	-a "" == "${A[VERSION_SUBMOD_NAME]}"  -a "" == "${B[VERSION_SUBMOD_NAME]}" \
	-a "" == "${A[VERSION_SUBMOD_PATH]}"  -a "" == "${B[VERSION_SUBMOD_PATH]}" \
] || DIE 1 "[FAIL]  $0  WRONG DATA for contributor and its clone"

[ "true" == "$(HOOKS_EXIST contrib/.git)" ] && DIE 1 "[FAIL]  $0      UNWANTED HOOK FOUND"
[ "true" == "$(HOOKS_EXIST clone-m/.git)" ] && DIE 1 "[FAIL]  $0      UNWANTED HOOK FOUND"

echo "[ OK ]  $0      original contributor and its clone gives same results"

popd >/dev/null 2>&1
