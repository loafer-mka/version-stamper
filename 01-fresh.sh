#!/bin/bash

. "$(dirname "$0")/lib.sh"

pushd "$(dirname "$0")/repos" >/dev/null 2>&1

[ \
  -d "./bare0.git" -a -d "./bare1.git" -a \
  -d "./fresh"     -a -d "./contrib"   -a \
  -d "./clone-a"   -a -d "./clone-e"   -a -d "./clone-m" \
] || ../00-init-repos.sh

CLEAN_HOOKS "./fresh"

pushd fresh >/dev/null 2>&1
../../../version-stamper -p | LOAD_A | while read L ; do eval $L; done
popd >/dev/null 2>&1
../../version-stamper -p -cd fresh | LOAD_B | while read L ; do eval $L; done

# PRINT_A_B

[ \
	-n "${A[VERSION_TEXT]}" -a -n "${B[VERSION_TEXT]}" -a "${A[VERSION_TEXT]}" == "${B[VERSION_TEXT]}" \
	-a "0000000000000000000000000000000000000000" == "${A[VERSION_SHA]}" \
	-a "0000000000000000000000000000000000000000" == "${B[VERSION_SHA]}" \
	-a "00000000" == "${A[VERSION_HEX]}" -a "00000000" == "${B[VERSION_HEX]}" \
] || DIE 1 "[FAIL]  $0  WRONG DATA"

[ "true" == "$(HOOKS_EXIST "./fresh")" ] && DIE 1 "[FAIL]  $0  UNWANTED HOOK FOUND"

echo "[ OK ]  $0"

CLEAN_HOOKS "./fresh"

popd >/dev/null 2>&1
