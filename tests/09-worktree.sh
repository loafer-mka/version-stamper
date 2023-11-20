#!/bin/bash

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

[ -d "./worktree" ] && rm -rf "./worktree"
mkdir worktree
cd contrib
# repair is a new command, many git setups does not support it
# git --no-pager worktree repair ../worktree 2>/dev/null 1>&2
git --no-pager worktree add --force ../worktree SUBMOD0 2>/dev/null 1>&2
cd ../worktree
git reset --hard HEAD >/dev/null
cd ..

../../version-stamper --directory worktree -p 2>/dev/null | LOAD_A
../../version-stamper --directory worktree/sub1 -p 2>/dev/null | LOAD_B

#PRINT_A_B

[ \
	   "v0.0-17.SUBMOD0" == "${A[VERSION_TEXT]}" \
	-a "v0.0-27.U" == "${B[VERSION_TEXT]}" \
	-a "v" == "${A[VERSION_PREFIX]}"       -a "v" == "${B[VERSION_PREFIX]}" \
	-a "0" == "${A[VERSION_MAJOR]}"        -a "0" == "${B[VERSION_MAJOR]}" \
	-a "0" == "${A[VERSION_MINOR]}"        -a "0" == "${B[VERSION_MINOR]}" \
	-a "17" == "${A[VERSION_BUILD]}"       -a "27" == "${B[VERSION_BUILD]}" \
	-a "SUBMOD0" == "${A[VERSION_BRANCH]}" -a "U" == "${B[VERSION_BRANCH]}" \
	-a "00000011" == "${A[VERSION_ID]}"    -a "0000001B" == "${B[VERSION_ID]}" \
	-a "" == "${A[VERSION_DIRTY]}"         -a "" == "${B[VERSION_DIRTY]}" \
	-a "" == "${A[VERSION_LEADER]}"        -a "ORIGIN_ONE_U_" == "${B[VERSION_LEADER]}" \
	-a "" == "${A[VERSION_TRAILER]}"       -a "" == "${A[VERSION_TRAILER]}"\
	-a "0000000000000000000000000000000000000000" != "${A[VERSION_SHA_LONG]}" \
	-a "0000000000000000000000000000000000000000" != "${B[VERSION_SHA_LONG]}" \
	-a "${A[VERSION_SHA_LONG]}" != "${B[VERSION_SHA_LONG]}" \
	-a "${A[VERSION_SHA_SHORT]}" != "${B[VERSION_SHA_SHORT]}" \
	-a "" == "${A[VERSION_SUBMOD_NAME]}" \
	-a "ORIGIN_ONE-U" == "${B[VERSION_SUBMOD_NAME]}" \
	-a "" == "${A[VERSION_SUBMOD_PATH]}" \
	-a "sub1" == "${B[VERSION_SUBMOD_PATH]}" \
] || DIE 1 "[FAIL]  $0   WRONG VERSION DATA for worktree and worktree with submodule"

[ "true" == "$(HOOKS_EXIST contrib/.git)" ] && DIE 1 "[FAIL]  $0   UNWANTED HOOK FOUND FOR worktree"
[ "true" == "$(HOOKS_EXIST contrib/.git/worktrees/worktree/modules/ORIGIN_ONE-U)" ] && DIE 1 "[FAIL]  $0   UNWANTED HOOK FOUND FOR worktree/sub1"

echo "[ OK ]  $0   Version data for worktree and worktree with submodule"

CLEANUP

../../version-stamper --directory contrib/sub0w -p 2>/dev/null | LOAD_A
../../version-stamper --directory clone-m/subM/sub2 -p 2>/dev/null | LOAD_B

#PRINT_A_B

[ \
	   "v0.0-12.F" == "${A[VERSION_TEXT]}" \
	-a "v0.0-20.ONE/N" == "${B[VERSION_TEXT]}" \
	-a "v" == "${A[VERSION_PREFIX]}"       -a "v" == "${B[VERSION_PREFIX]}" \
	-a "0" == "${A[VERSION_MAJOR]}"        -a "0" == "${B[VERSION_MAJOR]}" \
	-a "0" == "${A[VERSION_MINOR]}"        -a "0" == "${B[VERSION_MINOR]}" \
	-a "12" == "${A[VERSION_BUILD]}"       -a "20" == "${B[VERSION_BUILD]}" \
	-a "F" == "${A[VERSION_BRANCH]}"       -a "ONE/N" == "${B[VERSION_BRANCH]}" \
	-a "0000000C" == "${A[VERSION_ID]}"    -a "00000014" == "${B[VERSION_ID]}" \
	-a "" == "${A[VERSION_DIRTY]}"         -a "" == "${B[VERSION_DIRTY]}" \
	-a "" == "${A[VERSION_LEADER]}"        -a "ORIGIN_ONE_N_" == "${B[VERSION_LEADER]}" \
	-a "" == "${A[VERSION_TRAILER]}"       -a "" == "${A[VERSION_TRAILER]}"\
	-a "0000000000000000000000000000000000000000" != "${A[VERSION_SHA_LONG]}" \
	-a "0000000000000000000000000000000000000000" != "${B[VERSION_SHA_LONG]}" \
	-a "${A[VERSION_SHA_LONG]}" != "${B[VERSION_SHA_LONG]}" \
	-a "${A[VERSION_SHA_SHORT]}" != "${B[VERSION_SHA_SHORT]}" \
	-a "" == "${A[VERSION_SUBMOD_NAME]}" \
	-a "ORIGIN-ONE_N" == "${B[VERSION_SUBMOD_NAME]}" \
	-a "" == "${A[VERSION_SUBMOD_PATH]}" \
	-a "sub2" == "${B[VERSION_SUBMOD_PATH]}" \
] || DIE 1 "[FAIL]  $0   WRONG VERSIN DATA for worktree of submodule and submodule of submodule"

[ "true" == "$(HOOKS_EXIST contrib/.git/modules/ORIGIN_ONE-U0)" ] && DIE 1 "[FAIL]  $0   UNWANTED HOOK FOUND FOR contrib/sub0w"
[ "true" == "$(HOOKS_EXIST clone-m/.git/modules/ORIGIN_ONE-SUBMOD0/modules/ORIGIN-ONE_N)" ] && DIE 1 "[FAIL]  $0   UNWANTED HOOK FOUND FOR clone-m/subM/sub2"

echo "[ OK ]  $0   Version data for worktree of submodule and submodule of submodule"

popd >/dev/null 2>&1
