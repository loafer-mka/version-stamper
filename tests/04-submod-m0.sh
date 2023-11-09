#!/bin/bash

. "$(dirname "$0")/lib.sh"

pushd "$(dirname "$0")/repos" >/dev/null 2>&1

[ \
  -d "./bare0.git" -a -d "./bare1.git" -a \
  -d "./fresh"     -a -d "./contrib"   -a \
  -d "./detach-f"  -a -d "./detach-p"   -a \
  -d "./clone-a"   -a -d "./clone-e"   -a -d "./clone-m" \
] || ../00-init-repos.sh

CLEAN_HOOKS contrib/.git/modules/origin_one-U0
CLEAN_HOOKS clone-m/.git/modules/origin_one-U0

../../version-stamper --directory contrib/sub0 -p | LOAD_A
../../version-stamper --directory clone-m/sub0 -p | LOAD_B

#PRINT_A_B

[ \
	   "v0.0-21.U0" == "${A[VERSION_TEXT]}" \
	-a "v0.0-21.U0" == "${B[VERSION_TEXT]}" \
	-a "v" == "${A[VERSION_PREFIX]}"      -a "v" == "${B[VERSION_PREFIX]}" \
	-a "0" == "${A[VERSION_MAJOR]}"       -a "0" == "${B[VERSION_MAJOR]}" \
	-a "0" == "${A[VERSION_MINOR]}"       -a "0" == "${B[VERSION_MINOR]}" \
	-a "21" == "${A[VERSION_BUILD]}"      -a "21" == "${B[VERSION_BUILD]}" \
	-a "U0" == "${A[VERSION_BRANCH]}"     -a "U0" == "${B[VERSION_BRANCH]}" \
	-a "00000015" == "${A[VERSION_HEX]}"  -a "00000015" == "${B[VERSION_HEX]}" \
	-a "" == "${A[VERSION_DIRTY]}"        -a "" == "${B[VERSION_DIRTY]}" \
	-a "ORIGIN_ONE_U0_" == "${A[VERSION_LEADER]}" \
	-a "ORIGIN_ONE_U0_" == "${B[VERSION_LEADER]}" \
	-a "" == "${A[VERSION_TRAILER]}"      -a "" == "${A[VERSION_TRAILER]}"\
	-a "0000000000000000000000000000000000000000" != "${A[VERSION_SHA]}" \
	-a "0000000000000000000000000000000000000000" != "${B[VERSION_SHA]}" \
	-a "${A[VERSION_SHA]}" == "${B[VERSION_SHA]}" \
	-a "${A[VERSION_SHA_ABBREV]}" == "${B[VERSION_SHA_ABBREV]}" \
	-a "origin_one-U0" == "${A[VERSION_SUBMOD_NAME]}" \
	-a "origin_one-U0" == "${B[VERSION_SUBMOD_NAME]}" \
	-a "sub0" == "${A[VERSION_SUBMOD_PATH]}" \
	-a "sub0" == "${B[VERSION_SUBMOD_PATH]}" \
] || DIE 1 "[FAIL]  $0  WRONG DATA"

[ "true" == "$(HOOKS_EXIST contrib/.git/modules/origin_one-U0)" ] && DIE 1 "[FAIL]  $0  UNWANTED HOOK FOUND FOR contrib/sub0"
[ "true" == "$(HOOKS_EXIST clone-m/.git/modules/origin_one-U0)" ] && DIE 1 "[FAIL]  $0  UNWANTED HOOK FOUND FOR clone-m/sub0"

echo "[ OK ]  $0  original submodule sub0 and its clone gives same results"

popd >/dev/null 2>&1
