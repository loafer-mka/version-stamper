#!/bin/bash

# disable history support; this enables 'echo "foo!"' (this sample with enabled history produces 'bash: !: event not found')
set +H
# disable monitor
set +m
# last function/builtin in pipe will run in current shell
shopt -s lastpipe

SPACE_ROW="                                                                                                                                                                     "
DELIM_ROW="---------------------------------------------------------------------------------------------------------------------------------------------------------------------"

declare -A A
declare -A B  

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
	while [ 0 -lt "$#" ]; do
		b=${#1}
		if [ $b -gt $a ]; then a=$b; fi
		shift
	done
	echo $a
}
function LOAD_A
{
	sed -r -n -e 's/^\s+(\w)/\1/; s/^(\w+)=\s*(\w.*)?$/A["\1"]="\2"/; s/^(A\[\"VERSION_.*)$/\1/p' | while read L ; do eval $L; done
}
function LOAD_B
{
	sed -r -n -e 's/^\s+(\w)/\1/; s/^(\w+)=\s*(\w.*)?$/B["\1"]="\2"/; s/^(B\[\"VERSION_.*)$/\1/p' | while read L ; do eval $L; done
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
		[ -f "$1/hooks/$f" ] && rm -f "$1/hooks/$f"
	done
}
function HOOKS_EXIST
{
	local path="$1"
	shift

	if [ 0 -eq "$#" ]; then
		HOOKS_EXIST "${path}" pre-commit post-checkout post-commit post-rewrite post-merge \
			prepare-commit-msg commit-msg applypatch-msg pre-applypatch post-applypatch pre-rebase pre-push pre-auto-gc \
			pre-receive update post-receive fsmonitor-watchman post-update
	else
		for h in "$@" ; do
			if [ -f "${path}/hooks/${h}" ]; then
				echo "true"
				return
			fi
		done
		echo "false"
	fi
}
