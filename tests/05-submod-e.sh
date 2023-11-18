#!/bin/bash

. "$(dirname "$0")/lib.sh"

pushd "$(dirname "$0")/repos" >/dev/null 2>&1

[ \
  -d "./bare0.git" -a -d "./bare1.git" -a \
  -d "./fresh"     -a -d "./contrib"   -a \
  -d "./detach-f"  -a -d "./detach-p"   -a \
  -d "./clone-a"   -a -d "./clone-e"   -a \
  -d "./clone-m"   -a -d "./worktree" \
] || ../000-init-repos.sh

[ -d "./clone-e" ] && rm -rf "./clone-e"
git --no-pager clone --branch SUBMOD ./bare0.git ./clone-e >/dev/null 2>&1

CLEAN_HOOKS clone-e/.git/modules/ORIGIN_ONE-U0
CLEAN_HOOKS clone-e/.git/modules/ORIGIN_ONE-U

A[DIR_A]="$(echo "$(ls ./clone-e/sub0)")"
B[DIR_A]="$(echo "$(ls ./clone-e/sub1)")"

../../version-stamper --directory clone-e/sub0 -p 2>/dev/null | LOAD_A
../../version-stamper --directory clone-e/sub1 -p 2>/dev/null | LOAD_B

A[DIR_B]="$(echo "$(ls -1 ./clone-e/sub0)")"
B[DIR_B]="$(echo "$(ls -1 ./clone-e/sub1)")"

#PRINT_A_B

[ \
	   "v0.0-21.U0" == "${A[VERSION_TEXT]}" \
	-a "v0.0-27.U" == "${B[VERSION_TEXT]}" \
	-a "v" == "${A[VERSION_PREFIX]}"      -a "v" == "${B[VERSION_PREFIX]}" \
	-a "0" == "${A[VERSION_MAJOR]}"       -a "0" == "${B[VERSION_MAJOR]}" \
	-a "0" == "${A[VERSION_MINOR]}"       -a "0" == "${B[VERSION_MINOR]}" \
	-a "21" == "${A[VERSION_BUILD]}"      -a "27" == "${B[VERSION_BUILD]}" \
	-a "U0" == "${A[VERSION_BRANCH]}"     -a "U" == "${B[VERSION_BRANCH]}" \
	-a "00000015" == "${A[VERSION_HEX]}"  -a "0000001B" == "${B[VERSION_HEX]}" \
	-a "" == "${A[VERSION_DIRTY]}"        -a "" == "${B[VERSION_DIRTY]}" \
	-a "ORIGIN_ONE_U0_" == "${A[VERSION_LEADER]}" \
	-a "ORIGIN_ONE_U_" == "${B[VERSION_LEADER]}" \
	-a "" == "${A[VERSION_TRAILER]}"      -a "" == "${A[VERSION_TRAILER]}"\
	-a "0000000000000000000000000000000000000000" != "${A[VERSION_SHA]}" \
	-a "0000000000000000000000000000000000000000" != "${B[VERSION_SHA]}" \
	-a "${A[VERSION_SHA]}" != "${B[VERSION_SHA]}" \
	-a "${A[VERSION_SHA_ABBREV]}" != "${B[VERSION_SHA_ABBREV]}" \
	-a "ORIGIN_ONE-U0" == "${A[VERSION_SUBMOD_NAME]}" \
	-a "ORIGIN_ONE-U" == "${B[VERSION_SUBMOD_NAME]}" \
	-a "sub0" == "${A[VERSION_SUBMOD_PATH]}" \
	-a "sub1" == "${B[VERSION_SUBMOD_PATH]}" \
	-a "" == "${A[DIR_A]}"                -a "" == "${B[DIR_A]}" \
	-a "README.txt" == "${A[DIR_B]}"      -a "README.txt" == "${A[DIR_B]}" \
] || DIE 1 "[FAIL]  $0  WRONG DATA"

[ "true" == "$(HOOKS_EXIST clone-e/.git/modules/ORIGIN_ONE-U0)" ] && DIE 1 "[FAIL]  $0   UNWANTED HOOK FOUND FOR clone-e/sub0"
[ "true" == "$(HOOKS_EXIST clone-e/.git/modules/ORIGIN_ONE-U)" ] && DIE 1 "[FAIL]  $0   UNWANTED HOOK FOUND FOR clone-e/sub1"

echo "[ OK ]  $0   fresh non-updated submodules sub0 and sub1 where updated ok"

# ======================================================================
CLEANUP
# ======================================================================

CLEAN_HOOKS clone-e/.git/modules/origin-one_N
CLEAN_HOOKS clone-e/.git/modules/origin-F

A[DIR_A]="$(ls ./clone-e/sub2)"
B[DIR_A]="$(ls ./clone-e/sub3)"

../../version-stamper --directory clone-e/sub2 -p 2>/dev/null | LOAD_A
../../version-stamper --directory clone-e/sub3 -p 2>/dev/null | LOAD_B

A[DIR_B]="$(ls ./clone-e/sub2)"
B[DIR_B]="$(ls ./clone-e/sub3)"

#PRINT_A_B

[ \
	   "v0.0-20.ONE/N" == "${A[VERSION_TEXT]}" \
	-a "v0.0-12.F" == "${B[VERSION_TEXT]}" \
	-a "v" == "${A[VERSION_PREFIX]}"      -a "v" == "${B[VERSION_PREFIX]}" \
	-a "0" == "${A[VERSION_MAJOR]}"       -a "0" == "${B[VERSION_MAJOR]}" \
	-a "0" == "${A[VERSION_MINOR]}"       -a "0" == "${B[VERSION_MINOR]}" \
	-a "20" == "${A[VERSION_BUILD]}"      -a "12" == "${B[VERSION_BUILD]}" \
	-a "ONE/N" == "${A[VERSION_BRANCH]}"  -a "F" == "${B[VERSION_BRANCH]}" \
	-a "00000014" == "${A[VERSION_HEX]}"  -a "0000000C" == "${B[VERSION_HEX]}" \
	-a "" == "${A[VERSION_DIRTY]}"        -a "" == "${B[VERSION_DIRTY]}" \
	-a "ORIGIN_ONE_N_" == "${A[VERSION_LEADER]}" \
	-a "ORIGIN_F_" == "${B[VERSION_LEADER]}" \
	-a "" == "${A[VERSION_TRAILER]}"      -a "" == "${A[VERSION_TRAILER]}"\
	-a "0000000000000000000000000000000000000000" != "${A[VERSION_SHA]}" \
	-a "0000000000000000000000000000000000000000" != "${B[VERSION_SHA]}" \
	-a "${A[VERSION_SHA]}" != "${B[VERSION_SHA]}" \
	-a "${A[VERSION_SHA_ABBREV]}" != "${B[VERSION_SHA_ABBREV]}" \
	-a "ORIGIN-ONE_N" == "${A[VERSION_SUBMOD_NAME]}" \
	-a "ORIGIN-F" == "${B[VERSION_SUBMOD_NAME]}" \
	-a "sub2" == "${A[VERSION_SUBMOD_PATH]}" \
	-a "sub3" == "${B[VERSION_SUBMOD_PATH]}" \
	-a "" == "${A[DIR_A]}"                -a "" == "${B[DIR_A]}" \
	-a "README.txt" == "${A[DIR_B]}"      -a "README.txt" == "${A[DIR_B]}" \
] || DIE 1 "[FAIL]  $0  WRONG DATA"

[ "true" == "$(HOOKS_EXIST clone-e/.git/modules/ORIGIN-ONE_N)" ] && DIE 1 "[FAIL]  $0   UNWANTED HOOK FOUND FOR clone-e/sub2"
[ "true" == "$(HOOKS_EXIST clone-e/.git/modules/ORIGIN-F)" ] && DIE 1 "[FAIL]  $0   UNWANTED HOOK FOUND FOR clone-e/sub3"

echo "[ OK ]  $0   fresh non-updated submodules sub2 and sub3 where updated ok"

popd >/dev/null 2>&1
