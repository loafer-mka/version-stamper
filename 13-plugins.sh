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

CLEAN_HOOKS contrib/.git
CLEAN_HOOKS clone-m/.git

../../version-stamper --directory contrib -p | LOAD_A

# PRINT_A_B

[ \
	   "v0.0.18-SUBMOD" == "${A[VERSION_TEXT]}" \
	-a "v" == "${A[VERSION_PREFIX]}" \
	-a "0" == "${A[VERSION_MAJOR]}" \
	-a "0" == "${A[VERSION_MINOR]}" \
	-a "18" == "${A[VERSION_BUILD]}" \
	-a "SUBMOD" == "${A[VERSION_BRANCH]}" \
	-a "00000012" == "${A[VERSION_ID]}" \
	-a "" == "${A[VERSION_DIRTY]}" \
	-a "" == "${A[VERSION_LEADER]}" \
	-a "" == "${A[VERSION_TRAILER]}" \
	-a "0000000000000000000000000000000000000000" != "${A[VERSION_SHA_LONG]}" \
	-a "" == "${A[VERSION_SUBMOD_NAME]}" \
	-a "" == "${A[VERSION_SUBMOD_PATH]}" \
] || DIE 1 "[FAIL]  $0  WRONG DATA for contributor"

[ "true" == "$(HOOKS_EXIST contrib/.git)" ] && DIE 1 "[FAIL]  $0      UNWANTED HOOK FOUND"

R="$(../../version-stamper --directory contrib BAD_PLUGIN - 2>/dev/null)"
[[ 0 -eq $? || -n ${R} ]] && DIE 2 "[FAIL]  $0      BAD PLUGIN WAS NOT DETECTED"

R="$(../../version-stamper --directory contrib INFO - 2>&1)"
[[ 0 -ne $? || ! ${R} =~ ^v0\.0\.18-SUBMOD\ +[0-9]{4}-[0-9]{2}-[0-9]{2}\ [0-9]{2}:[0-9]{2}:[0-9]{2}\ +clean\ +[0-9a-f]+\ +Stamper\ +Tests\ +\<stamper@test\.org\> ]] && DIE 2 "[FAIL]  $0      BAD INFO PLUGIN"
# v0.0.18-SUBMOD  2025-02-23 00:58:04  clean  b19cdae6  Stamper Tests <stamper@test.org>  "Add submodule with submodules"

R="$(../../version-stamper "" --directory "" contrib "" INFO "" - 2>&1)"
[[ 0 -ne $? || ! ${R} =~ ^v0\.0\.18-SUBMOD\ +[0-9]{4}-[0-9]{2}-[0-9]{2}\ [0-9]{2}:[0-9]{2}:[0-9]{2}\ +clean\ +[0-9a-f]+\ +Stamper\ +Tests\ +\<stamper@test\.org\> ]] && DIE 2 "[FAIL]  $0      BAD INFO PLUGIN WITH EMPTY ARGS"

R="$(echo "v1.1.1-NONE 1111-11-11 11:11:11  clean  11111111  Stamper Tests <stamper@test.org>  \"Add submodule\"" |../../version-stamper "" --directory "" contrib "" INFO "" -- 2>&1)"
[[ 0 -ne $? || ! ${R} =~ ^v0\.0\.18-SUBMOD\ +[0-9]{4}-[0-9]{2}-[0-9]{2}\ [0-9]{2}:[0-9]{2}:[0-9]{2}\ +clean\ +[0-9a-f]+\ +Stamper\ +Tests\ +\<stamper@test\.org\> ]] && DIE 2 "[FAIL]  $0      BAD INFO PLUGIN WITH EXISTING STAMP"


shopt -s lastpipe
shopt -s extglob

declare -i F=0
../../version-stamper --directory contrib BAT - 2>&1 |dos2unix |while read -r L; do
	case "${L}" in
	"" | "@echo off" | "rem "*)
		;;
	"set VERSION_ID=0x00000012")
		F=F+1
		;;
	"set VERSION_TEXT=v0.0.18-SUBMOD")
		F=F+2
		;;
	"set VERSION_DATE="[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]\ [0-9][0-9]:[0-9][0-9]:[0-9][0-9])
		F=F+4
		;;
	"set VERSION_SHORTDATE="[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9])
		F=F+8
		;;
	"set VERSION_UNIXTIME="[0-9]*[0-9])
		F=F+16
		;;
	"set VERSION_BRANCH="*)
		F=F+32
		;;
	"set VERSION_SHA_SHORT="[0-9a-fA-F][0-9a-fA-F][0-9a-fA-F]*[0-9a-fA-F][0-9a-fA-F][0-9a-fA-F])
		F=F+64
		;;
	"set VERSION_SHA_LONG="[0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F]*[0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F])
		F=F+128
		;;
	"for "*" in ("*") do set VERSION_HOSTINFO=%%a")
		F=F+256
		;;
	"for "*" in ("*") do set VERSION_AUTHORSHIP=%%a")
		F=F+512
		;;
	"for "*" in ("*") do set VERSION_DECLARATION=%%a")
		F=F+1024
		;;
	"for "*" in ("*") do set VERSION_COMMIT_AUTHOR=%%a")
		F=F+2048
		;;
	*)
		echo "> $L";
		;;
	esac
done
[[ 4095 -eq $F ]] || DIE 2 "[FAIL]  $0      BAD BAT PLUGIN"

F=0
../../version-stamper --directory contrib C - 2>&1 |dos2unix |while read -r L; do
	L="${L//+([[:space:]])/ }"
	case "${L}" in
	"" | "#ifndef __VERSION_GUARD_H__" | "# define __VERSION_GUARD_H__" | "#endif" | "//"*)
		;;
	"# define VERSION_ID 0x00000012L")
		F=F+1
		;;
	"# define VERSION_TEXT \"v0.0.18-SUBMOD\"")
		F=F+2
		;;
	"# define VERSION_DATE \""[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]\ [0-9][0-9]:[0-9][0-9]:[0-9][0-9]"\"")
		F=F+4
		;;
	"# define VERSION_SHORTDATE \""[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]"\"")
		F=F+8
		;;
	"# define VERSION_UNIXTIME "[0-9]*[0-9]"LL")
		F=F+16
		;;
	"# define VERSION_BRANCH \""*"\"")
		F=F+32
		;;
	"# define VERSION_SHA_SHORT \""[0-9a-fA-F][0-9a-fA-F][0-9a-fA-F]*[0-9a-fA-F][0-9a-fA-F][0-9a-fA-F]"\"")
		F=F+64
		;;
	"# define VERSION_SHA_LONG \""[0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F]*[0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F]"\"")
		F=F+128
		;;
	"# define VERSION_HOSTINFO \""*"\"")
		F=F+256
		;;
	"# define VERSION_AUTHORSHIP \""*"\"")
		F=F+512
		;;
	"# define VERSION_DECLARATION \""*"\"")
		F=F+1024
		;;
	"# define VERSION_COMMIT_AUTHOR \""*"\"")
		F=F+2048
		;;
	*)
		echo "> $L";
		;;
	esac
done
[[ 4095 -eq $F ]] || DIE 2 "[FAIL]  $0      BAD C PLUGIN"

F=0
../../version-stamper --directory contrib CMAKE - 2>&1 |dos2unix |while read -r L; do
	L="${L//+([[:space:]])/ }"
	case "${L}" in
	"" | "if( NOT DEFINED __VERSION_GUARD_CMAKE__ )" | "set( __VERSION_GUARD_CMAKE__ 1 )" | "endif()" | "#"*)
		;;
	"set( VERSION_ID \"00000012\" )")
		F=F+1
		;;
	"set( VERSION_TEXT \"v0.0.18-SUBMOD\" )")
		F=F+2
		;;
	"set( VERSION_DATE \""[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]\ [0-9][0-9]:[0-9][0-9]:[0-9][0-9]"\" )")
		F=F+4
		;;
	"set( VERSION_SHORTDATE \""[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]"\" )")
		F=F+8
		;;
	"set( VERSION_UNIXTIME \""[0-9]*[0-9]"\" )")
		F=F+16
		;;
	"set( VERSION_BRANCH \""*"\" )")
		F=F+32
		;;
	"set( VERSION_SHA_SHORT \""[0-9a-fA-F][0-9a-fA-F][0-9a-fA-F]*[0-9a-fA-F][0-9a-fA-F][0-9a-fA-F]"\" )")
		F=F+64
		;;
	"set( VERSION_SHA_LONG \""[0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F]*[0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F]"\" )")
		F=F+128
		;;
	"set( VERSION_HOSTINFO \""*"\" )")
		F=F+256
		;;
	"set( VERSION_AUTHORSHIP \""*"\" )")
		F=F+512
		;;
	"set( VERSION_DECLARATION \""*"\" )")
		F=F+1024
		;;
	"set( VERSION_COMMIT_AUTHOR \""*"\" )")
		F=F+2048
		;;
	*)
		echo "> $L";
		;;
	esac
done
[[ 4095 -eq $F ]] || DIE 2 "[FAIL]  $0      BAD CMAKE PLUGIN"

F=0
../../version-stamper --directory contrib CS - 2>&1 |dos2unix |while read -r L; do
	L="${L//\([[:space:]]\"/(\"}"
	L="${L//\"[[:space:]]\)/\")}"
	case "${L}" in
	"" | "//"* | "using System."* | "NOTE:"* | "The "*)
		;;
	"[assembly: AssemblyTitle(\""*"\")]")
		F=F+1
		;;
	"[assembly: AssemblyDescription(\""*"\")]")
		F=F+2
		;;
	"[assembly: AssemblyConfiguration(\""*"\")]")
		F=F+4
		;;
	"[assembly: AssemblyCompany(\""*"\")]")
		F=F+8
		;;
	"[assembly: AssemblyProduct(\""*"\")]")
		F=F+16
		;;
	"[assembly: AssemblyCopyright(\""*"\")]")
		F=F+32
		;;
	"[assembly: AssemblyTrademark(\""*"\")]")
		F=F+64
		;;
	"[assembly: AssemblyCulture(\""*"\")]")
		F=F+128
		;;
	"[assembly: ComVisible(false)]" | "[assembly: ComVisible(true)]")
		F=F+256
		;;
	"[assembly: Guid(\""[0-9A-F][0-9A-F][0-9A-F][0-9A-F][0-9A-F][0-9A-F][0-9A-F][0-9A-F]-[0-9A-F][0-9A-F][0-9A-F][0-9A-F]-[0-9A-F][0-9A-F][0-9A-F][0-9A-F]-[0-9A-F][0-9A-F][0-9A-F][0-9A-F]-[0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F]"\")]")
		F=F+512
		;;
	"[assembly: AssemblyVersion(\"0.0.18."*"\")]")
		F=F+1024
		;;
	"[assembly: AssemblyFileVersion(\"0.0.18."*"\")]")
		F=F+2048
		;;
	"[assembly: AssemblyInformationalVersion(\"v0.0.18-SUBMOD "[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]\ [0-9][0-9]:[0-9][0-9]:[0-9][0-9]\ *\ [0-9a-fA-F][0-9a-fA-F]*[0-9a-fA-F][0-9a-fA-F]"\")]")
		F=F+4096
		;;
	*)
		echo "> $L";
		;;
	esac
done
[[ 8191 -eq $F ]] || DIE 2 "[FAIL]  $0      BAD CS PLUGIN"


F=0
../../version-stamper --directory contrib M - 2>&1 |dos2unix |while read -r L; do
	L="${L//+([[:space:]])/ }"
	case "${L}" in
	"" | "classdef VERSION" | "properties (Constant)" | "end" | "%"*)
		;;
	"VERSION_ID = hex2dec('00000012');")
		F=F+1
		;;
	"VERSION_HEX = '0x00000012';")
		;;
	"VERSION_TEXT = 'v0.0.18-SUBMOD';")
		F=F+2
		;;
	"VERSION_DATE = '"[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]\ [0-9][0-9]:[0-9][0-9]:[0-9][0-9]"';")
		F=F+4
		;;
	"VERSION_SHORTDATE = '"[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]"';")
		F=F+8
		;;
	"VERSION_UNIXTIME = "[0-9]*[0-9]";")
		F=F+16
		;;
	"VERSION_BRANCH = 'SUBMOD';")
		F=F+32
		;;
	"VERSION_SHA_SHORT = '"[0-9a-fA-F][0-9a-fA-F][0-9a-fA-F]*[0-9a-fA-F][0-9a-fA-F][0-9a-fA-F]"';")
		F=F+64
		;;
	"VERSION_SHA_LONG = '"[0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F]*[0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F]"';")
		F=F+128
		;;
	"VERSION_HOSTINFO = '"*"';")
		F=F+256
		;;
	"VERSION_AUTHORSHIP = '"*"';")
		F=F+512
		;;
	"VERSION_DECLARATION = '"*"';")
		F=F+1024
		;;
	"VERSION_COMMIT_AUTHOR = '"*"';")
		F=F+2048
		;;
	*)
		echo "> $L";
		;;
	esac
done
[[ 4095 -eq $F ]] || DIE 2 "[FAIL]  $0      BAD M PLUGIN"

F=0
../../version-stamper --directory contrib MAKEFILE - 2>&1 |dos2unix |while read -r L; do
	L="${L//+([[:space:]])/ }"
	case "${L}" in
	"" | "#"*)
		;;
	"VERSION_ID := 00000012")
		F=F+1
		;;
	"VERSION_TEXT := v0.0.18-SUBMOD")
		F=F+2
		;;
	"VERSION_DATE := "[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]\ [0-9][0-9]:[0-9][0-9]:[0-9][0-9])
		F=F+4
		;;
	"VERSION_SHORTDATE := "[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9])
		F=F+8
		;;
	"VERSION_UNIXTIME := "[0-9]*[0-9])
		F=F+16
		;;
	"VERSION_BRANCH := SUBMOD")
		F=F+32
		;;
	"VERSION_SHA_SHORT := "[0-9a-fA-F][0-9a-fA-F][0-9a-fA-F]*[0-9a-fA-F][0-9a-fA-F][0-9a-fA-F])
		F=F+64
		;;
	"VERSION_SHA_LONG := "[0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F]*[0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F])
		F=F+128
		;;
	"VERSION_HOSTINFO := "*)
		F=F+256
		;;
	"VERSION_AUTHORSHIP := "*)
		F=F+512
		;;
	"VERSION_DECLARATION := "*)
		F=F+1024
		;;
	"VERSION_COMMIT_AUTHOR := "*)
		F=F+2048
		;;
	*)
		echo "> $L";
		;;
	esac
done
[[ 4095 -eq $F ]] || DIE 2 "[FAIL]  $0      BAD MAKEFILE PLUGIN"

F=0
../../version-stamper --directory contrib MARKDOWN - 2>&1 |dos2unix |while read -r L; do
	L="${L//+([[:space:]])/ }"
	case "${L}" in
	"" | "|--------:|:----------------|" | "| Worktree | clean |" | "#"*)
		;;
	"| Version | v0.0.18-SUBMOD |")
		F=F+1
		;;
	"| Version ID | 0x00000012 |")
		F=F+2
		;;
	"| Date | "[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]\ [0-9][0-9]:[0-9][0-9]:[0-9][0-9]" |")
		F=F+4
		;;
	"| Commiter | "*" |")
		F=F+8
		;;
	"| Unix Time | "[0-9]*[0-9]" |")
		F=F+16
		;;
	"| Branch | SUBMOD |")
		F=F+32
		;;
	"| Commit SHA | "[0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F]*[0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F]" |")
		F=F+64
		;;
	"| Build Host | "*" |")
		F=F+128
		;;
	"| Folder | \`"*"\` |")
		F=F+256
		;;
	"| | Copyright "*" |")
		F=F+512
		;;
	*)
		# echo "> $L";
		;;
	esac
done
[[ 1023 -eq $F ]] || DIE 2 "[FAIL]  $0      BAD MARKDOWN PLUGIN"

F=0
../../version-stamper --directory contrib SH - 2>&1 |dos2unix |while read -r L; do
	L="${L//+([[:space:]])/ }"
	case "${L}" in
	"" | "#"*)
		;;
	"VERSION_ID=0x00000012")
		F=F+1
		;;
	"VERSION_TEXT=\"v0.0.18-SUBMOD\"")
		F=F+2
		;;
	"VERSION_DATE=\""[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]\ [0-9][0-9]:[0-9][0-9]:[0-9][0-9]"\"")
		F=F+4
		;;
	"VERSION_SHORTDATE=\""[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]"\"")
		F=F+8
		;;
	"VERSION_UNIXTIME=\""[0-9]*[0-9]"\"")
		F=F+16
		;;
	"VERSION_BRANCH=\"SUBMOD\"")
		F=F+32
		;;
	"VERSION_SHA_SHORT=\""[0-9a-fA-F][0-9a-fA-F][0-9a-fA-F]*[0-9a-fA-F][0-9a-fA-F][0-9a-fA-F]"\"")
		F=F+64
		;;
	"VERSION_SHA_LONG=\""[0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F]*[0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F]"\"")
		F=F+128
		;;
	"VERSION_HOSTINFO=\""*"\"")
		F=F+256
		;;
	"VERSION_AUTHORSHIP=\""*"\"")
		F=F+512
		;;
	"VERSION_DECLARATION=\""*"\"")
		F=F+1024
		;;
	"VERSION_COMMIT_AUTHOR=\""*"\"")
		F=F+2048
		;;
	*)
		echo "> $L";
		;;
	esac
done
[[ 4095 -eq $F ]] || DIE 2 "[FAIL]  $0      BAD SH PLUGIN"

echo "[ OK ]  $0      plugins BAT C CS INFO M MAKEFILE MARKDOWN SH work ok"

# BAT C CMAKE CS INFO M MAKEFILE MARKDOWN SH
# M

popd >/dev/null 2>&1
