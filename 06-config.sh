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
CLEAN_WORKTREE fresh

cd fresh

../../../version-stamper -c

unset C
declare -A C

[ -f ".version-stamper" ] && C["F:.version-stamper"]="found"
[ -f ".gitattributes" ] && C["F:.gitattributes"]="found"

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
		C["BAD"]="${C[BAD]} ${P}"
		;;
	esac
done

CLEAN_WORKTREE .

#for i in "${!C[@]}" ; do echo "$i"; done | sort | while read i ; do echo "C[$i] = ${C[$i]}" ; done

[ \
       "" == "${C[BAD]}" \
    -a "found" == "${C[F:.version-stamper]}"  -a "found" == "${C[F:.gitattributes]}" \
    -a "" != "${C[C:authorship]}"             -a "" != "${C[C:declaration]}" \
    -a "" != "${C[C:default-cmd]}"            -a "" != "${C[C:hooks]}" \
    -a "text eol=lf" == "${C[A:.gitignore]}"  -a "text eol=lf" == "${C[A:.gitattributes]}" \
    -a "text eol=lf" == "${C[A:.gitmodules]}" -a "text" == "${C[A:.version-stamper]}" \
] || DIE 1 "[FAIL]  $0     Mandatory parameters were not set"

[ "true" != "$(HOOKS_EXIST .git)" ] && DIE 1 "[FAIL]  $0     WANTED HOOKS ARE FOUND FOR fresh"

echo "[ OK ]  $0     Add default configuration into empty project"

popd >/dev/null 2>&1
