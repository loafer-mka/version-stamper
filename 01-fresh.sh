#!/bin/bash

. "$(dirname "$0")/lib.sh"

pushd "$(dirname "$0")/repos" >/dev/null 2>&1

[ \
  -d "./bare0.git" -a -d "./bare1.git" -a \
  -d "./fresh"     -a -d "./contrib"   -a \
  -d "./clone-a"   -a -d "./clone-e"   -a -d "./clone-m" \
] || ../00-init-repos.sh

CLEAN_HOOKS "./fresh"

# check for fresh repo
pushd fresh >/dev/null 2>&1
../../../version-stamper -p | LOAD_A
popd >/dev/null 2>&1
# check for -cd option and fresh repo
../../version-stamper -p -cd fresh | LOAD_B

# PRINT_A_B

[ \
	   "v0.0-0.master" == "${A[VERSION_TEXT]}" \
	-a "v0.0-0.master" == "${B[VERSION_TEXT]}" \
	-a "v" == "${A[VERSION_PREFIX]}" -a "v" == "${B[VERSION_PREFIX]}" \
	-a "0" == "${A[VERSION_MAJOR]}" -a "0" == "${B[VERSION_MAJOR]}" \
	-a "0" == "${A[VERSION_MINOR]}" -a "0" == "${B[VERSION_MINOR]}" \
	-a "0" == "${A[VERSION_BUILD]}" -a "0" == "${B[VERSION_BUILD]}" \
	-a "0000000000000000000000000000000000000000" == "${A[VERSION_SHA]}" \
	-a "0000000000000000000000000000000000000000" == "${B[VERSION_SHA]}" \
	-a "00000000" == "${A[VERSION_HEX]}" -a "00000000" == "${B[VERSION_HEX]}" \
	-a "" == "${A[VERSION_SUBMOD_NAME]}" -a "" == "${B[VERSION_SUBMOD_NAME]}" \
	-a "" == "${A[VERSION_SUBMOD_PATH]}" -a "" == "${B[VERSION_SUBMOD_PATH]}" \
] || DIE 1 "[FAIL]  $0  WRONG DATA"

[ "true" == "$(HOOKS_EXIST "./fresh")" ] && DIE 1 "[FAIL]  $0  UNWANTED HOOK FOUND"

echo "[ OK ]  $0     empty repository; hooks were not set; -cd option ok"

CLEAN_HOOKS "./fresh"

popd >/dev/null 2>&1
