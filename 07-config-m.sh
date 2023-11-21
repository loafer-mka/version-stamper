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
  -d "./bare0.git" -a -d "./bare1.git" -a \
  -d "./fresh"     -a -d "./contrib"   -a \
  -d "./detach-f"  -a -d "./detach-p"   -a \
  -d "./clone-a"   -a -d "./clone-e"   -a \
  -d "./clone-m"   -a -d "./worktree" \
] || ../000-init-repos.sh

CLEAN_HOOKS contrib/.git
CLEAN_WORKTREE contrib

unset C
declare -Ag C

cd contrib

for f in .* * ; do [ -f "$f" ] && C["0:$f"]="found"; done

../../../version-stamper -c

for f in .* * ; do [ -f "$f" ] && C["1:$f"]="found" ; done

cat .version-stamper 2>/dev/null | grep -v -E "^\s*#|^\s*$" | while read P V ; do
	case "$P" in
	authorship: | declaration: | default-cmd: | hooks: | abbrev: | leader: | trailer: | verbose: | plugin-*:)
		C["C:${P%:}"]="${V}"
		;;
	*)
		C["BAD"]="${C[BAD]} ${P%:}"
		;;
	esac
done
cat .gitattributes 2>/dev/null | grep -v -E "^\s*#|^\s*$" | while read P V ; do
	case "$P" in
	.gitignore | .gitmodules | .gitattributes | .version-stamper | README.txt)
		C["A:${P}"]="${V}"
		;;
	*)
		# allow any other files in non-empty projects
		;;
	esac
done

sed -i -r -e 's/^\s*#\s*plugin-C:.*$/plugin-C: --gitignore ver.h/' \
	 -e 's/^\s*#\s*plugin-CS:.*$/plugin-CS: --gitattributes ver.cs/' \
	 -e 's/^\s*#\s*plugin-BAT:.*$/plugin-BAT: ver.bat/' \
	 -e 's/^\s*#\s*plugin-SH:.*$/plugin-SH: -i ver.sh/' \
	 -e 's/^\s*#\s*plugin-MAKEFILE:.*$/plugin-MAKEFILE: -a ver.mk/' \
	 ${WIN_SED_EOL} \
	.version-stamper

../../../version-stamper -g M -i ver.m >/dev/null 2>&1

for f in .* * ; do [ -f "$f" ] && C["2:$f"]="found" ; done

source ver.sh
../../../version-stamper -p | LOAD_A

HOOKS_FLAG="$(HOOKS_EXIST .git)"
CLEAN_HOOKS .git
CLEAN_WORKTREE .

# for i in "${!C[@]}" ; do echo "$i"; done | sort | while read i ; do echo "C[$i] = ${C[$i]}" ; done
# for v in "${!VERSION_@}" ; do echo "$v"; done | sort | while read v ; do declare -n z=$v; echo "$v = $z" ; done
# for i in "${!A[@]}" ; do echo "$i"; done | sort | while read i ; do echo "A[$i] = ${A[$i]}" ; done

[ \
       "found" == "${C[0:.gitmodules]}"       -a "found" == "${C[0:README.txt]}" \
    -a "found" == "${C[1:.gitmodules]}"       -a "found" == "${C[1:README.txt]}" \
    -a "found" == "${C[1:.version-stamper]}"  -a "found" == "${C[1:.gitattributes]}" \
    -a "found" == "${C[2:.gitmodules]}"       -a "found" == "${C[2:README.txt]}" \
    -a "found" == "${C[2:.version-stamper]}"  -a "found" == "${C[2:.gitattributes]}" \
    -a "found" == "${C[2:ver.h]}"             -a "found" == "${C[2:ver.cs]}" \
    -a "found" == "${C[2:ver.bat]}"           -a "found" == "${C[2:ver.sh]}" \
    -a "found" == "${C[2:ver.mk]}"            -a "found" == "${C[2:ver.m]}" \
    -a "" != "${C[C:authorship]}"             -a "" != "${C[C:declaration]}" \
    -a "" != "${C[C:default-cmd]}"            -a "" != "${C[C:hooks]}" \
    -a "text eol=lf" == "${C[A:.gitignore]}"  -a "text eol=lf" == "${C[A:.gitattributes]}" \
    -a "text eol=lf" == "${C[A:.gitmodules]}" -a "text" == "${C[A:.version-stamper]}" \
\
	-a "v0.0-18.SUBMOD+" == "${A[VERSION_TEXT]}" \
	-a "v0.0-18.SUBMOD+" == "${VERSION_TEXT}" \
	-a "+" == "${A[VERSION_DIRTY]}" \
	-a "SUBMOD" == "${A[VERSION_BRANCH]}"     -a "SUBMOD+" == "${VERSION_BRANCH}" \
	-a "00000012" == "${A[VERSION_ID]}"       -a "0x00000012" == "${VERSION_ID}" \
	-a "${A[VERSION_SHA_LONG]}" == "${VERSION_SHA_LONG}" \
	-a "${A[VERSION_SHA_SHORT]}" == "${VERSION_SHA_SHORT}" \
	-a "" == "${A[VERSION_SUBMOD_NAME]}"  \
	-a "" == "${A[VERSION_SUBMOD_PATH]}"  \
] || DIE 1 "[FAIL]  $0   Mandatory parameters were not set"

[ \
	   "" == "${C[BAD]}" \
    -a "found" != "${C[0:.version-stamper]}"  -a "found" != "${C[0:ver.mk]}" \
    -a "found" != "${C[0:ver.h]}"             -a "found" != "${C[0:ver.cs]}" \
    -a "found" != "${C[0:ver.bat]}"           -a "found" != "${C[0:ver.sh]}" \
    -a "found" != "${C[1:ver.h]}"             -a "found" != "${C[1:ver.cs]}" \
    -a "found" != "${C[1:ver.bat]}"           -a "found" != "${C[1:ver.sh]}" \
    -a "found" != "${C[1:ver.mk]}" \
] || DIE 1 "[FAIL]  $0     Wrong parameters presented"

[ "true" != "${HOOKS_FLAG}" ] && DIE 1 "[FAIL]  $0   WANTED HOOKS ARE NOT FOUND FOR contrib"

echo "[ OK ]  $0   Add default configuration into complex project"

popd >/dev/null 2>&1
