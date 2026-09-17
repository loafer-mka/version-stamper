#!/bin/bash

# +--------------------------------------------------------------------+
# | This Source Code Form is subject to the terms of the Mozilla       |
# | Public License, v. 2.0. If a copy of the MPL was not distributed   |
# | with this file, You can obtain one at http://mozilla.org/MPL/2.0/. |
# +--------------------------------------------------------------------+
#        email: Andrey Makarov <mka-at-mailru@mail.ru>
# Project home: https://github.com/loafer-mka/version-stamper.git
#
#               Copyright (c) Andrey Makarov 2026

. "$(dirname "$0")/lib.sh"

pushd "$(dirname "$0")/repos" >/dev/null 2>&1

[ \
  -d "./bare0.git" -a -d "./bare1.git"   -a \
  -d "./fresh"     -a -d "./contrib"     -a \
  -d "./detach-f"  -a -d "./detach-p"    -a \
  -d "./clone-a"   -a -d "./clone-e"     -a \
  -d "./clone-x"   -a -d "./clone-x.git" -a \
  -d "./clone-m"   -a -d "./worktree"    -a \
  -d "./customdir" \
] || ../000-init-repos.sh

CLEAN_HOOKS customdir/.git

declare -A A B

A["VERSION_ID"]="0x01021103"
A["VERSION_TEXT"]="_x1.1.3-F_"
A["VERSION_PREFIX"]="_x_"
A["VERSION_MAJOR"]="1"
A["VERSION_MINOR"]="2"
A["VERSION_BUILD"]="4355"
A["VERSION_BRANCH"]="_F_"
A["VERSION_DIRTY"]="-"
A["VERSION_DATE"]="1024-01-01 00:00:00"
A["VERSION_SHORTDATE"]="240101000000"
A["VERSION_SHA_LONG"]="1111111111111111111111111111111111111111"
A["VERSION_SHA_SHORT"]="11111111"
A["VERSION_HOSTINFO"]="xxx@yyy.zzz test system"
A["VERSION_AUTHORSHIP"]="XXX YYY"
A["VERSION_DECLARATION"]="Copyright (c) XXX YYY 2022"
A["VERSION_SUBMOD_NAME"]="unknown"
A["VERSION_SUBMOD_PATH"]="unknown"
A["VERSION_COMMIT_AUTHOR"]="XXX YYY"
A["VERSION_COMMIT_EMAIL"]="xxx@yyy.zzz"
A["VERSION_LEADER"]="CUSTOM_"
A["VERSION_TRAILER"]="_DIR"

pushd customdir >/dev/null 2>&1
../../../version-stamper -p | LOAD_B
popd >/dev/null 2>&1

#PRINT_A_B

[ \
	   "${A[VERSION_ID]}" == "${B[VERSION_ID]}" \
	-a "${A[VERSION_TEXT]}" == "${B[VERSION_TEXT]}" \
	-a "${A[VERSION_PREFIX]}" == "${B[VERSION_PREFIX]}" \
	-a "${A[VERSION_MAJOR]}" == "${B[VERSION_MAJOR]}" \
	-a "${A[VERSION_MINOR]}" == "${B[VERSION_MINOR]}" \
	-a "${A[VERSION_BUILD]}" == "${B[VERSION_BUILD]}" \
	-a "${A[VERSION_BRANCH]}" == "${B[VERSION_BRANCH]}" \
	-a "${A[VERSION_DIRTY]}" == "${B[VERSION_DIRTY]}" \
	-a "${A[VERSION_DATE]}" == "${B[VERSION_DATE]}" \
	-a "${A[VERSION_SHORTDATE]}" == "${B[VERSION_SHORTDATE]}" \
	-a "${A[VERSION_SHA_LONG]}" == "${B[VERSION_SHA_LONG]}" \
	-a "${A[VERSION_SHA_SHORT]}" == "${B[VERSION_SHA_SHORT]}" \
	-a "${A[VERSION_HOSTINFO]}" == "${B[VERSION_HOSTINFO]}" \
	-a "${A[VERSION_AUTHORSHIP]}" == "${B[VERSION_AUTHORSHIP]}" \
	-a "${A[VERSION_DECLARATION]}" == "${B[VERSION_DECLARATION]}" \
	-a "${A[VERSION_SUBMOD_NAME]}" == "${B[VERSION_SUBMOD_NAME]}" \
	-a "${A[VERSION_SUBMOD_PATH]}" == "${B[VERSION_SUBMOD_PATH]}" \
	-a "${A[VERSION_COMMIT_AUTHOR]}" == "${B[VERSION_COMMIT_AUTHOR]}" \
	-a "${A[VERSION_COMMIT_EMAIL]}" == "${B[VERSION_COMMIT_EMAIL]}" \
	-a "${A[VERSION_LEADER]}" == "${B[VERSION_LEADER]}" \
	-a "${A[VERSION_TRAILER]}" == "${B[VERSION_TRAILER]}" \
] || DIE 1 "[FAIL]  $0  WRONG DATA"

[ "true" == "$(HOOKS_EXIST fresh/.git)" ] && DIE 1 "[FAIL]  $0  UNWANTED HOOK FOUND"

echo "[ OK ]  $0 custom-dir option allows to add custom plugins and textoize scripts"

CLEAN_HOOKS fresh/.git

popd >/dev/null 2>&1
