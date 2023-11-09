#!/bin/bash

. "$(dirname "$0")/lib.sh"

pushd "$(dirname "$0")/repos" >/dev/null 2>&1

[ \
  -d "./bare0.git" -a -d "./bare1.git" -a \
  -d "./fresh"     -a -d "./contrib"   -a \
  -d "./detach-f"  -a -d "./detach-p"   -a \
  -d "./clone-a"   -a -d "./clone-e"   -a -d "./clone-m" \
] || ../00-init-repos.sh

CLEAN_HOOKS detach-p/.git
CLEAN_HOOKS detach-f/.git

# check for detached head
pushd detach-p >/dev/null 2>&1
../../../version-stamper -p | LOAD_A
popd >/dev/null 2>&1
# check for detached head ands --directory option
../../version-stamper --directory detach-f -p | LOAD_B

#PRINT_A_B

[ \
	   "x1.2-4.F" == "${A[VERSION_TEXT]}" \
	-a "x1.2-13.F" == "${B[VERSION_TEXT]}" \
	-a "x" == "${A[VERSION_PREFIX]}"      -a "x" == "${B[VERSION_PREFIX]}" \
	-a "1" == "${A[VERSION_MAJOR]}"       -a "1" == "${B[VERSION_MAJOR]}" \
	-a "2" == "${A[VERSION_MINOR]}"       -a "2" == "${B[VERSION_MINOR]}" \
	-a "4" == "${A[VERSION_BUILD]}"       -a "13" == "${B[VERSION_BUILD]}" \
	-a "F" == "${A[VERSION_BRANCH]}"      -a "F" == "${B[VERSION_BRANCH]}" \
	-a "01020004" == "${A[VERSION_HEX]}"  -a "0102000D" == "${B[VERSION_HEX]}" \
	-a "" == "${A[VERSION_DIRTY]}"        -a "" == "${B[VERSION_DIRTY]}" \
	-a "" == "${A[VERSION_LEADER]}"       -a "" == "${B[VERSION_LEADER]}" \
	-a "" == "${A[VERSION_TRAILER]}"      -a "" == "${A[VERSION_TRAILER]}"\
	-a "0000000000000000000000000000000000000000" != "${A[VERSION_SHA]}" \
	-a "0000000000000000000000000000000000000000" != "${B[VERSION_SHA]}" \
	-a "${A[VERSION_SHA]}" != "${B[VERSION_SHA]}" \
	-a "${A[VERSION_SHA_ABBREV]}" != "${B[VERSION_SHA_ABBREV]}" \
	-a "" == "${A[VERSION_SUBMOD_NAME]}"  -a "" == "${B[VERSION_SUBMOD_NAME]}" \
	-a "" == "${A[VERSION_SUBMOD_PATH]}"  -a "" == "${B[VERSION_SUBMOD_PATH]}" \
] || DIE 1 "[FAIL]  $0  WRONG DATA"

[ "true" == "$(HOOKS_EXIST detach-p/.git)" ] && DIE 1 "[FAIL]  $0  UNWANTED HOOK FOUND FOR detach-p"
[ "true" == "$(HOOKS_EXIST detach-f/.git)" ] && DIE 1 "[FAIL]  $0  UNWANTED HOOK FOUND FOR detach-f"

echo "[ OK ]  $0     detached head in past and in future; hooks were not set; --directory option ok"

popd >/dev/null 2>&1
