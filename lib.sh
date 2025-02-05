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

# disable history support; this enables 'echo "foo!"' (this sample with enabled history produces 'bash: !: event not found')
set +H
# disable monitor
set +m
# last function/builtin in pipe will run in current shell
shopt -s lastpipe

SPACE_ROW="                                                                                                                                                                     "
DELIM_ROW="---------------------------------------------------------------------------------------------------------------------------------------------------------------------"

function CLEANUP
{
	unset A
	unset B
	declare -Ag A
	declare -Ag B
}
function DIE
{
	local 	res=$1
	shift
	echo "$@" 1>&2
	exit ${res}
}
function LEN
{
	local 	a=${#1}
	local 	b

	shift
	while [[ 0 -lt "$#" ]]; do
		b=${#1}
		if [[ $b -gt $a ]]; then a=$b; fi
		shift
	done
	echo $a
}
function LOAD_A
{
	sed -r -n -e 's/^\s+(\w)/\1/; s/^(\w+)=\s*([_+[:alnum:]].*)?$/A["\1"]="\2"/; s/^(A\[\"VERSION_.*)$/\1/p' | while read L ; do eval $L ; done
}
function LOAD_B
{
	sed -r -n -e 's/^\s+(\w)/\1/; s/^(\w+)=\s*([_+[:alnum:]].*)?$/B["\1"]="\2"/; s/^(B\[\"VERSION_.*)$/\1/p' | while read L ; do eval $L ; done
}
function PRINT_A_B
{
	len1=$(LEN "${!A[@]}")
	len2=$(LEN "${A[@]}")
	len3=$(LEN "${B[@]}")
	echo "+${DELIM_ROW:0:${len1}+2}+${DELIM_ROW:0:${len2}+2}+${DELIM_ROW:0:${len2}+2}+"
	for v in "${!A[@]}" ; do
		echo "| ${v}${SPACE_ROW:0:${len1}-${#v}} | ${A[$v]}${SPACE_ROW:0:${len2}-${#A[$v]}} | ${B[$v]}${SPACE_ROW:0:${len2}-${#B[$v]}} |"
	done
	echo "+${DELIM_ROW:0:${len1}+2}+${DELIM_ROW:0:${len2}+2}+${DELIM_ROW:0:${len2}+2}+"
}
function CLEAN_HOOKS
{
	for f in \
		pre-commit post-checkout post-commit post-rewrite post-merge \
		prepare-commit-msg commit-msg applypatch-msg pre-applypatch post-applypatch pre-rebase pre-push pre-auto-gc \
		pre-receive update post-receive fsmonitor-watchman post-update ; \
	do
		[[ -f $1/hooks/$f ]] && rm -f "$1/hooks/$f"
	done
}
function HOOKS_EXIST
{
	local path="$1"
	shift

	if [[ 0 -eq "$#" ]]; then
		HOOKS_EXIST "${path}" pre-commit post-checkout post-commit post-rewrite post-merge \
			prepare-commit-msg commit-msg applypatch-msg pre-applypatch post-applypatch pre-rebase pre-push pre-auto-gc \
			pre-receive update post-receive fsmonitor-watchman post-update
	else
		for h in "$@" ; do
			if [[ -f ${path}/hooks/${h} ]]; then
				echo "true"
				return
			fi
		done
		echo "false"
	fi
}
function CLEAN_WORKTREE
{
	pushd "$1" >/dev/null 2>&1
	BRANCH="$(git --no-pager rev-parse --abbrev-ref HEAD 2>/dev/null)"
	[[ "HEAD" == ${BRANCH} ]] && BRANCH=""

	# echo "======== DO CLEAN WORKTREE"
	git --no-pager status --porcelain --ignored | while read S N rest ; do
		# echo ">> $S $N"
		case "${S}" in
		"??" | "!!")
			# echo "> rm $N"
			rm -f "$N" >/dev/null 2>&1		# igored or not added
			;;
		"A" | "AM" | "AT" | "AD" | "DD" | "AU" | "UD" | "UA" | "DU" | "AA" | "UU")
			# echo "> git rm $N"
			git rm --force "$N" >/dev/null 2>&1
			;;
		*)
			# echo "> git checkout --force ${BRANCH} -- $N"
			git checkout --force ${BRANCH} -- "$N"
		esac
	done
	# echo "======== AFTER CLEAN WORKTREE"
	# git --no-pager status --porcelain
	# echo "======== DONE CLEAN WORKTREE"
	popd >/dev/null 2>&1
}
function GIT_INIT
{
	#
	# "$1" must be folder path
	#

	#
	# note: current git needs in renamed default branch; i.e. must be used:
	#
	# --initial-branch master 
	#    or
	# -c init.defaultBranch=master
	#
	# both are ok for my current git (v2.35.3) but ...
	# git for windows 2.21.0.windows.1 does not known option --initial-branch (or -b) yet (unsupported option is an error)
	# and it does not apply init.defaultBranch configuration (unsupported configuration parameter is not error)
	#
	# so ... use '-c init.defaultBranch=master' only, so you avoid warnings about
	# branch renaming and have same branch 'master' as for old git.
	#
	git --no-pager -c init.defaultBranch=MASTER init "$@"
	pushd "$1" >/dev/null 2>&1
	sed -i -e 's/master/MASTER/' .git/HEAD 2>/dev/null 1>&2
	git --no-pager config --local user.name "Stamper Tests"
	git --no-pager config --local user.email "stamper@test.org"
	popd >/dev/null 2>&1
}

if [[ "Windows_NT" == ${OS} ]]; then
	WIN_SED_EOL="-e s/$/\r/"
	WIN_ECHO_EOL="$(echo -en "\r")"
else
	WIN_SED_EOL=""
	WIN_ECHO_EOL=""
fi

[[ -d "$(dirname "$0")/repos" ]] || mkdir "$(dirname "$0")/repos"

CLEANUP
