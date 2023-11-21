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

../../version-stamper -p -cd fresh | LOAD_A
sleep 2s
../../version-stamper -p -cd fresh | LOAD_B
((D=B["VERSION_UNIXTIME"]-A["VERSION_UNIXTIME"]))

# PRINT_A_B
# echo "D=$D"

# VERSION_DATE, VERSION_SHORTDATE, VERSION_UNIXTIME - is a time of
# version-stamper run, so it may be same or may differs for 1..2 sec.

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
	-a "${A[VERSION_UNIXTIME]}" != "${B[VERSION_UNIXTIME]}" \
	-a "${A[VERSION_SHORTDATE]}" != "${B[VERSION_SHORTDATE]}" \
	-a "${A[VERSION_DATE]}" != "${B[VERSION_DATE]}" \
	-a "0000000000000000000000000000000000000000" == "${A[VERSION_SHA_LONG]}" \
	-a "0000000000000000000000000000000000000000" == "${B[VERSION_SHA_LONG]}" \
	-a "" == "${A[VERSION_SUBMOD_NAME]}"  -a "" == "${B[VERSION_SUBMOD_NAME]}" \
	-a "" == "${A[VERSION_SUBMOD_PATH]}"  -a "" == "${B[VERSION_SUBMOD_PATH]}" \
	-a $D -le 5 -a 1 -le $D \
] || DIE 1 "[FAIL]  $0       WRONG DATA for fresh"

[ "true" == "$(HOOKS_EXIST fresh/.git)" ] && DIE 1 "[FAIL]  $0       UNWANTED HOOK FOUND FOR fresh"

echo "[ OK ]  $0       two query for empty repository with 2s pause - timestamps differs for $D seconds"

popd >/dev/null 2>&1
