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

CLEAN_HOOKS contrib/.git/modules/ORIGIN_ONE-U0
CLEAN_HOOKS clone-m/.git/modules/ORIGIN_ONE-U0

../../version-stamper --directory contrib/sub0 -p | LOAD_A
../../version-stamper --directory clone-m/sub0 -p | LOAD_B

#PRINT_A_B

[ \
	   "v0.0.21-U0" == "${A[VERSION_TEXT]}" \
	-a "v0.0.21-U0" == "${B[VERSION_TEXT]}" \
	-a "v" == "${A[VERSION_PREFIX]}"      -a "v" == "${B[VERSION_PREFIX]}" \
	-a "0" == "${A[VERSION_MAJOR]}"       -a "0" == "${B[VERSION_MAJOR]}" \
	-a "0" == "${A[VERSION_MINOR]}"       -a "0" == "${B[VERSION_MINOR]}" \
	-a "21" == "${A[VERSION_BUILD]}"      -a "21" == "${B[VERSION_BUILD]}" \
	-a "U0" == "${A[VERSION_BRANCH]}"     -a "U0" == "${B[VERSION_BRANCH]}" \
	-a "00000015" == "${A[VERSION_ID]}"   -a "00000015" == "${B[VERSION_ID]}" \
	-a "" == "${A[VERSION_DIRTY]}"        -a "" == "${B[VERSION_DIRTY]}" \
	-a "ORIGIN_ONE_U0_" == "${A[VERSION_LEADER]}" \
	-a "ORIGIN_ONE_U0_" == "${B[VERSION_LEADER]}" \
	-a "" == "${A[VERSION_TRAILER]}"      -a "" == "${A[VERSION_TRAILER]}"\
	-a "0000000000000000000000000000000000000000" != "${A[VERSION_SHA_LONG]}" \
	-a "0000000000000000000000000000000000000000" != "${B[VERSION_SHA_LONG]}" \
	-a "${A[VERSION_SHA_LONG]}" == "${B[VERSION_SHA_LONG]}" \
	-a "${A[VERSION_SHA_SHORT]}" == "${B[VERSION_SHA_SHORT]}" \
	-a "ORIGIN_ONE-U0" == "${A[VERSION_SUBMOD_NAME]}" \
	-a "ORIGIN_ONE-U0" == "${B[VERSION_SUBMOD_NAME]}" \
	-a "sub0" == "${A[VERSION_SUBMOD_PATH]}" \
	-a "sub0" == "${B[VERSION_SUBMOD_PATH]}" \
] || DIE 1 "[FAIL]  $0   WRONG DATA for submodule sub0 and its clone"

[ "true" == "$(HOOKS_EXIST contrib/.git/modules/ORIGIN_ONE-U0)" ] && DIE 1 "[FAIL]  $0   UNWANTED HOOK FOUND FOR contrib/sub0"
[ "true" == "$(HOOKS_EXIST clone-m/.git/modules/ORIGIN_ONE-U0)" ] && DIE 1 "[FAIL]  $0   UNWANTED HOOK FOUND FOR clone-m/sub0"

echo "[ OK ]  $0   original submodule sub0 and its clone gives same results"

# ======================================================================
CLEANUP
# ======================================================================

CLEAN_HOOKS contrib/.git/modules/origin_one-U
CLEAN_HOOKS clone-m/.git/modules/origin_one-U

../../version-stamper --directory contrib/sub1 -p | LOAD_A
../../version-stamper --directory clone-m/sub1 -p | LOAD_B

# PRINT_A_B

[ \
	   "v0.0.27-U" == "${A[VERSION_TEXT]}" \
	-a "v0.0.27-U" == "${B[VERSION_TEXT]}" \
	-a "v" == "${A[VERSION_PREFIX]}"      -a "v" == "${B[VERSION_PREFIX]}" \
	-a "0" == "${A[VERSION_MAJOR]}"       -a "0" == "${B[VERSION_MAJOR]}" \
	-a "0" == "${A[VERSION_MINOR]}"       -a "0" == "${B[VERSION_MINOR]}" \
	-a "27" == "${A[VERSION_BUILD]}"      -a "27" == "${B[VERSION_BUILD]}" \
	-a "U" == "${A[VERSION_BRANCH]}"      -a "U" == "${B[VERSION_BRANCH]}" \
	-a "0000001B" == "${A[VERSION_ID]}"   -a "0000001B" == "${B[VERSION_ID]}" \
	-a "" == "${A[VERSION_DIRTY]}"        -a "" == "${B[VERSION_DIRTY]}" \
	-a "ORIGIN_ONE_U_" == "${A[VERSION_LEADER]}" \
	-a "ORIGIN_ONE_U_" == "${B[VERSION_LEADER]}" \
	-a "" == "${A[VERSION_TRAILER]}"      -a "" == "${A[VERSION_TRAILER]}"\
	-a "0000000000000000000000000000000000000000" != "${A[VERSION_SHA_LONG]}" \
	-a "0000000000000000000000000000000000000000" != "${B[VERSION_SHA_LONG]}" \
	-a "${A[VERSION_SHA_LONG]}" == "${B[VERSION_SHA_LONG]}" \
	-a "${A[VERSION_SHA_SHORT]}" == "${B[VERSION_SHA_SHORT]}" \
	-a "ORIGIN_ONE-U" == "${A[VERSION_SUBMOD_NAME]}" \
	-a "ORIGIN_ONE-U" == "${B[VERSION_SUBMOD_NAME]}" \
	-a "sub1" == "${A[VERSION_SUBMOD_PATH]}" \
	-a "sub1" == "${B[VERSION_SUBMOD_PATH]}" \
] || DIE 1 "[FAIL]  $0   WRONG DATA for submodule sub1 and its clone"

[ "true" == "$(HOOKS_EXIST contrib/.git/modules/ORIGIN_ONE-U)" ] && DIE 1 "[FAIL]  $0   UNWANTED HOOK FOUND FOR contrib/sub1"
[ "true" == "$(HOOKS_EXIST clone-m/.git/modules/ORIGIN_ONE-U)" ] && DIE 1 "[FAIL]  $0   UNWANTED HOOK FOUND FOR clone-m/sub1"

echo "[ OK ]  $0   original submodule sub1 and its clone gives same results"

# ======================================================================
CLEANUP
# ======================================================================

CLEAN_HOOKS contrib/.git/modules/origin-one_N
CLEAN_HOOKS clone-m/.git/modules/origin-one_N

../../version-stamper --directory contrib/sub2 -p | LOAD_A
../../version-stamper --directory clone-m/sub2 -p | LOAD_B

# PRINT_A_B

[ \
	   "v0.0.20-ONE/N" == "${A[VERSION_TEXT]}" \
	-a "v0.0.20-ONE/N" == "${B[VERSION_TEXT]}" \
	-a "v" == "${A[VERSION_PREFIX]}"      -a "v" == "${B[VERSION_PREFIX]}" \
	-a "0" == "${A[VERSION_MAJOR]}"       -a "0" == "${B[VERSION_MAJOR]}" \
	-a "0" == "${A[VERSION_MINOR]}"       -a "0" == "${B[VERSION_MINOR]}" \
	-a "20" == "${A[VERSION_BUILD]}"      -a "20" == "${B[VERSION_BUILD]}" \
	-a "ONE/N" == "${A[VERSION_BRANCH]}"  -a "ONE/N" == "${B[VERSION_BRANCH]}" \
	-a "00000014" == "${A[VERSION_ID]}"   -a "00000014" == "${B[VERSION_ID]}" \
	-a "" == "${A[VERSION_DIRTY]}"        -a "" == "${B[VERSION_DIRTY]}" \
	-a "ORIGIN_ONE_N_" == "${A[VERSION_LEADER]}" \
	-a "ORIGIN_ONE_N_" == "${B[VERSION_LEADER]}" \
	-a "" == "${A[VERSION_TRAILER]}"      -a "" == "${A[VERSION_TRAILER]}"\
	-a "0000000000000000000000000000000000000000" != "${A[VERSION_SHA_LONG]}" \
	-a "0000000000000000000000000000000000000000" != "${B[VERSION_SHA_LONG]}" \
	-a "${A[VERSION_SHA_LONG]}" == "${B[VERSION_SHA_LONG]}" \
	-a "${A[VERSION_SHA_SHORT]}" == "${B[VERSION_SHA_SHORT]}" \
	-a "ORIGIN-ONE_N" == "${A[VERSION_SUBMOD_NAME]}" \
	-a "ORIGIN-ONE_N" == "${B[VERSION_SUBMOD_NAME]}" \
	-a "sub2" == "${A[VERSION_SUBMOD_PATH]}" \
	-a "sub2" == "${B[VERSION_SUBMOD_PATH]}" \
] || DIE 1 "[FAIL]  $0   WRONG DATA for submodule sub2 and its clone"

[ "true" == "$(HOOKS_EXIST contrib/.git/modules/ORIGIN-ONE_N)" ] && DIE 1 "[FAIL]  $0   UNWANTED HOOK FOUND FOR contrib/sub2"
[ "true" == "$(HOOKS_EXIST clone-m/.git/modules/ORIGIN-ONE_N)" ] && DIE 1 "[FAIL]  $0   UNWANTED HOOK FOUND FOR clone-m/sub2"

echo "[ OK ]  $0   original submodule sub2 and its clone gives same results"


# ======================================================================
CLEANUP
# ======================================================================

CLEAN_HOOKS contrib/.git/modules/origin-F
CLEAN_HOOKS clone-m/.git/modules/origin-F

../../version-stamper --directory contrib/sub3 -p | LOAD_A
../../version-stamper --directory clone-m/sub3 -p | LOAD_B

# PRINT_A_B

[ \
	   "v0.0.12-F" == "${A[VERSION_TEXT]}" \
	-a "v0.0.12-F" == "${B[VERSION_TEXT]}" \
	-a "v" == "${A[VERSION_PREFIX]}"      -a "v" == "${B[VERSION_PREFIX]}" \
	-a "0" == "${A[VERSION_MAJOR]}"       -a "0" == "${B[VERSION_MAJOR]}" \
	-a "0" == "${A[VERSION_MINOR]}"       -a "0" == "${B[VERSION_MINOR]}" \
	-a "12" == "${A[VERSION_BUILD]}"      -a "12" == "${B[VERSION_BUILD]}" \
	-a "F" == "${A[VERSION_BRANCH]}"      -a "F" == "${B[VERSION_BRANCH]}" \
	-a "0000000C" == "${A[VERSION_ID]}"   -a "0000000C" == "${B[VERSION_ID]}" \
	-a "" == "${A[VERSION_DIRTY]}"        -a "" == "${B[VERSION_DIRTY]}" \
	-a "ORIGIN_F_" == "${A[VERSION_LEADER]}" \
	-a "ORIGIN_F_" == "${B[VERSION_LEADER]}" \
	-a "" == "${A[VERSION_TRAILER]}"      -a "" == "${A[VERSION_TRAILER]}"\
	-a "0000000000000000000000000000000000000000" != "${A[VERSION_SHA_LONG]}" \
	-a "0000000000000000000000000000000000000000" != "${B[VERSION_SHA_LONG]}" \
	-a "${A[VERSION_SHA_LONG]}" == "${B[VERSION_SHA_LONG]}" \
	-a "${A[VERSION_SHA_SHORT]}" == "${B[VERSION_SHA_SHORT]}" \
	-a "ORIGIN-F" == "${A[VERSION_SUBMOD_NAME]}" \
	-a "ORIGIN-F" == "${B[VERSION_SUBMOD_NAME]}" \
	-a "sub3" == "${A[VERSION_SUBMOD_PATH]}" \
	-a "sub3" == "${B[VERSION_SUBMOD_PATH]}" \
] || DIE 1 "[FAIL]  $0   WRONG DATA for submodule sub3 and its clone"

[ "true" == "$(HOOKS_EXIST contrib/.git/modules/ORIGIN-F)" ] && DIE 1 "[FAIL]  $0   UNWANTED HOOK FOUND FOR contrib/sub3"
[ "true" == "$(HOOKS_EXIST clone-m/.git/modules/ORIGIN-F)" ] && DIE 1 "[FAIL]  $0   UNWANTED HOOK FOUND FOR clone-m/sub3"

echo "[ OK ]  $0   original submodule sub3 and its clone gives same results"

popd >/dev/null 2>&1
