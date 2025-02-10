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

MSG=""

cd clone-a

git reset --hard origin/MASTER	>/dev/null 2>&1
CLEAN_HOOKS .git
CLEAN_WORKTREE .

# FILES varname folder [folder [folder [...]]]
function LOAD_FILES
{
    local   var=$1
    shift
    unset ${var}
    declare -Ag ${var}
    
    [ -z "$1" ] && set -- "."
    
    while [ -n "$1" ]; do
        if [ "." == "$1" ]; then
            p=""
        else
            p="$1/"
        fi
        for f in "$p".* "$p"* ; do
            case "${f##*/}" in
            .. | . | *.sample)
                # nothing
                ;;
            *)
                if [ -f "$f" ]; then
                    eval ${var}["$f"]="$f"
                elif [ -d "$f" ]; then
                    eval ${var}["$f/"]="$f"
                fi
                ;;
            esac
        done
        shift
    done
}
# LOAD_CHANGES varname
function LOAD_CHANGES
{
    unset $1
    declare -Ag $1
    git status --porcelain \
        | sed -r -e 's/^[A-Z?! ][A-Z?! ]\s+//' \
        | while read f; do eval $1["$f"]="$f"; done
}
function PRINT_ARRAY
{
    declare -n v=$1

    for i in "${!v[@]}"; do echo "$i"; done \
        | sort --ignore-case \
        | while read i; do echo " $1[ $i ] = '${v[$i]}'"; done
}


# ------ stage 0: get initial state ------
LOAD_FILES F0 . .git/hooks
LOAD_CHANGES C0
# PRINT_ARRAY F0
# PRINT_ARRAY C0


# ------ stage 1: create configuration ------
../../../version-stamper -c -s

# post-commit will be stored in config but not installed now
sed -i -r -e 's/^\s*(#\s*)?plugin-SH:.*$/plugin-SH: -a ver.sh/' \
    -e 's/^\s*(#\s*)?hooks:.*$/hooks: pre-commit  post-commit  post-checkout  post-rewrite  post-merge/' \
    -e 's/^\s*(#\s*)?leader:.*$/leader: A2_/' \
    ${WIN_SED_EOL} \
    .version-stamper

LOAD_FILES F1 . .git/hooks
LOAD_CHANGES C1
# PRINT_ARRAY F1
# PRINT_ARRAY C1


# ------ stage 2: create initial version ------
../../../version-stamper -s -g  2>/dev/null

LOAD_FILES F2 . .git/hooks
LOAD_CHANGES C2
source ver.sh

# PRINT_ARRAY F2
# PRINT_ARRAY C2
# for i in "${!A2_@}"; do echo "$i"; done | sort --ignore-case | while read i; do declare -n v=$i; echo " $i = '$v'"; done


# ------ stage 3: create few commits ------

# ------ stage 3a: create commit ------
sed -i -r -e 's/^\s*(#\s*)?leader:.*$/leader: A3_/' \
    ${WIN_SED_EOL} \
    .version-stamper

#sed -i -r -e 's/^\s*A2_/A3_/' ver.sh	# prefix A2_ must be chaned to A3_

echo "1st test commit${WIN_ECHO_EOL}" >>README.txt
git --no-pager commit -am "1st test commit" >/dev/null

LOAD_FILES F3 . .git/hooks
LOAD_CHANGES C3
source ver.sh

# git --no-pager log --oneline -n 5
# PRINT_ARRAY F3
# PRINT_ARRAY C3
# for i in "${!A3_@}"; do echo "$i"; done | sort --ignore-case | while read i; do declare -n v=$i; echo " $i = '$v'"; done

# ------ stage 3b: create commit ------
sed -i -r -e 's/^\s*(#\s*)?leader:.*$/leader: A4_/' \
    ${WIN_SED_EOL} \
    .version-stamper

#sed -i -r -e 's/^\s*A3_/A4_/' ver.sh	# prefix A3_ must be chaned to A4_

echo "2nd test commit${WIN_ECHO_EOL}" >>README.txt
git --no-pager commit -am "2nd test commit" >/dev/null

LOAD_FILES F4 . .git/hooks
LOAD_CHANGES C4
source ver.sh

# git --no-pager log --oneline -n 5
# PRINT_ARRAY F4
# PRINT_ARRAY C4
# for i in "${!A4_@}"; do echo "$i"; done | sort --ignore-case | while read i; do declare -n v=$i; echo " $i = '$v'"; done

# ------ stage 3c: create commit ------
sed -i -r -e 's/^\s*(#\s*)?leader:.*$/leader: A5_/' \
    ${WIN_SED_EOL} \
    .version-stamper

#sed -i -r -e 's/^\s*A4_/A5_/' ver.sh	# prefix A4_ must be chaned to A5_

echo "3rd test commit${WIN_ECHO_EOL}" >>README.txt
git --no-pager commit -am "3rd test commit" >/dev/null

LOAD_FILES F5 . .git/hooks
LOAD_CHANGES C5
source ver.sh

# git --no-pager log --oneline -n 5
# PRINT_ARRAY F5
# PRINT_ARRAY C5
# for i in "${!A5_@}"; do echo "$i"; done | sort --ignore-case | while read i; do declare -n v=$i; echo " $i = '$v'"; done


# ------ stage 4: prepare to squash ------
SHA=$(git --no-pager rev-parse HEAD)
git reset --hard origin/MASTER >/dev/null

#
# we now at MASTER head: no .version-stamper, no ver.sh files
# (we may squash one commit less, so stamper will be configured
# or we may create new commit here <- we will do that)
#
git checkout ${SHA} -- .version-stamper >/dev/null
git checkout ${SHA} -- .gitattributes >/dev/null
git checkout ${SHA} -- ver.sh >/dev/null

sed -i -r -e 's/^\s*(#\s*)?leader:.*$/leader: A7_/' \
	${WIN_SED_EOL} \
    .version-stamper

#sed -i -r -e 's/^\s*A[0-9]_/A7_/' ver.sh	# prefix A?_ must be chaned to A7_

# note: we cannot change prefix before merge (work tree must be clean!)
# so we will create configuration and target as for A7_ suffix and then
# rename variables to save current info before merge
echo "pre-squash commit${WIN_ECHO_EOL}" >>README.txt
git --no-pager commit -am "pre-squash commit" >/dev/null

LOAD_FILES F6 . .git/hooks
LOAD_CHANGES C6
source ver.sh		# here A7_... loaded, rename them
for i in "${!A7_@}"; do declare -n v=$i; eval A6${i#A7}="'$v'"; done

# git --no-pager log --oneline --graph -n 6 HEAD ${SHA}
# PRINT_ARRAY F6
# PRINT_ARRAY C6
# for i in "${!A6_@}"; do echo "$i"; done | sort --ignore-case | while read i; do declare -n v=$i; echo " $i = '$v'"; done

# ------ stage 5: squash commit ------
git merge --squash ${SHA} >/dev/null

# merge does not create commit, so we do that ...
# of course, some files may remains damaged after merge
# normally we must fix this manually before commit, but now we ignore this
echo "merge-squash commit${WIN_ECHO_EOL}" >>README.txt
git --no-pager commit -am "merge-squash commit" >/dev/null

LOAD_FILES F7 . .git/hooks
LOAD_CHANGES C7
source ver.sh

# git --no-pager log --oneline -n 5
# PRINT_ARRAY F7
# PRINT_ARRAY C7
# for i in "${!A7_@}"; do echo "$i"; done | sort --ignore-case | while read i; do declare -n v=$i; echo " $i = '$v'"; done


# ------ stage final: verify results ------
[ \
       "3" == "${#F0[@]}"           				-a "0" == "${#C0[@]}" \
    -a -n "${F0[README.txt]}"       				-a -n "${F0[.gitattributes]}" \
    -a -n "${F0[.git/]}" \
] || MSG="Bad initial state"

[ \
       "8" == "${#F1[@]}"           				-a "2" == "${#C1[@]}" \
    -a -n "${F1[README.txt]}"       				-a -n "${F1[.gitattributes]}" \
    -a -n "${F1[.version-stamper]}" 				-a -n "${F1[.git/]}" \
    -a -n "${F1[.git/hooks/post-checkout]}" 		-a -n "${F1[.git/hooks/post-merge]}" \
    -a -n "${F1[.git/hooks/post-rewrite]}" 			-a -n "${F1[.git/hooks/pre-commit]}" \
    -a -n "${C1[.gitattributes]}"					-a -n "${C1[.version-stamper]}" \
] || MSG="$MSG; Bad configuration"

[ \
       "10" == "${#F2[@]}"           				-a "3" == "${#C2[@]}" \
    -a -n "${F2[README.txt]}"       				-a -n "${F2[.gitattributes]}" \
    -a -n "${F2[.version-stamper]}" 				-a -n "${F2[ver.sh]}" \
    -a -n "${F2[.git/]}"     						-a -n "${F2[.git/hooks/post-checkout]}" \
    -a -n "${F2[.git/hooks/post-commit]}" 			-a -n "${F2[.git/hooks/post-merge]}" \
    -a -n "${F2[.git/hooks/post-rewrite]}" 			-a -n "${F2[.git/hooks/pre-commit]}" \
    -a -n "${C2[.gitattributes]}"					-a -n "${C2[.version-stamper]}" \
    -a -n "${C2[ver.sh]}" 							-a "v0.0.26-MASTER+" == "${A2_VERSION_TEXT}" \
] || MSG="$MSG; Bad state v0.0.26"

[ \
       "10" == "${#F3[@]}"           				-a "0" == "${#C3[@]}" \
    -a -n "${F3[README.txt]}"       				-a -n "${F3[.gitattributes]}" \
    -a -n "${F3[.version-stamper]}" 				-a -n "${F3[ver.sh]}" \
    -a -n "${F3[.git/]}"     						-a -n "${F3[.git/hooks/post-checkout]}" \
    -a -n "${F3[.git/hooks/post-commit]}" 			-a -n "${F3[.git/hooks/post-merge]}" \
    -a -n "${F3[.git/hooks/post-rewrite]}" 			-a -n "${F3[.git/hooks/pre-commit]}" \
    -a "v0.0.27-MASTER" == "${A3_VERSION_TEXT}" 	-a "${A2_VERSION_SHA_LONG}" != "${A3_VERSION_SHA_LONG}" \
] || MSG="$MSG; Bad commit v0.0.27"

[ \
       "10" == "${#F4[@]}"           				-a "0" == "${#C4[@]}" \
    -a -n "${F4[README.txt]}"       				-a -n "${F4[.gitattributes]}" \
    -a -n "${F4[.version-stamper]}" 				-a -n "${F4[ver.sh]}" \
    -a -n "${F4[.git/]}"     						-a -n "${F4[.git/hooks/post-checkout]}" \
    -a -n "${F4[.git/hooks/post-commit]}" 			-a -n "${F4[.git/hooks/post-merge]}" \
    -a -n "${F4[.git/hooks/post-rewrite]}" 			-a -n "${F4[.git/hooks/pre-commit]}" \
    -a "v0.0.28-MASTER" == "${A4_VERSION_TEXT}"		-a "${A3_VERSION_SHA_LONG}" != "${A4_VERSION_SHA_LONG}" \
] || MSG="$MSG; Bad commit v0.0.28"

[ \
       "10" == "${#F5[@]}"           				-a "0" == "${#C5[@]}" \
    -a -n "${F5[README.txt]}"       				-a -n "${F5[.gitattributes]}" \
    -a -n "${F5[.version-stamper]}" 				-a -n "${F5[ver.sh]}" \
    -a -n "${F5[.git/]}"     						-a -n "${F5[.git/hooks/post-checkout]}" \
    -a -n "${F5[.git/hooks/post-commit]}" 			-a -n "${F5[.git/hooks/post-merge]}" \
    -a -n "${F5[.git/hooks/post-rewrite]}" 			-a -n "${F5[.git/hooks/pre-commit]}" \
    -a "v0.0.29-MASTER" == "${A5_VERSION_TEXT}"		-a "${A4_VERSION_SHA_LONG}" != "${A5_VERSION_SHA_LONG}" \
] || MSG="$MSG; Bad commit v0.0.29"

#[ "10" == "${#F5[@]}" ] || echo "wrong count of files"
#[ "0" == "${#C5[@]}" ] || echo "changes detected"
#[ -n "${F5[README.txt]}" ] || echo "not exist README.txt"
#[ -n "${F5[.gitattributes]}" ] || echo "not exist .gitattributes"
#[ -n "${F5[.version-stamper]}" ] || echo "not exist .version-stamper"
#[ -n "${F5[ver.sh]}" ] || echo "not exist ver.sh"
#[ -n "${F5[.git/]}" ] || echo "not exist .git/"
#[ -n "${F5[.git/hooks/post-checkout]}" ] || echo "not exist post-checkout"
#[ -n "${F5[.git/hooks/post-commit]}" ] || echo "not exist post-commit"
#[ -n "${F5[.git/hooks/post-merge]}" ] || echo "not exist post-merge"
#[ -n "${F5[.git/hooks/post-rewrite]}" ] || echo "not exist post-rewrite"
#[ -n "${F5[.git/hooks/pre-commit]}" ] || echo "not exist pre-commit"
#[ "v0.0.29-MASTER" == "${A5_VERSION_TEXT}" ] || echo "bad version ${A5_VERSION_TEXT} must be v0.0.29-MASTER"
#[ "${A4_VERSION_SHA_LONG}" != "${A5_VERSION_SHA_LONG}" ] || echo "bad version ${A4_VERSION_SHA_LONG} != ${A5_VERSION_SHA_LONG}"

[ \
       "10" == "${#F6[@]}"           				-a "0" == "${#C6[@]}" \
    -a -n "${F6[README.txt]}"       				-a -n "${F6[.gitattributes]}" \
    -a -n "${F6[.version-stamper]}" 				-a -n "${F6[ver.sh]}" \
    -a -n "${F6[.git/]}"     						-a -n "${F6[.git/hooks/post-checkout]}" \
    -a -n "${F6[.git/hooks/post-commit]}" 			-a -n "${F6[.git/hooks/post-merge]}" \
    -a -n "${F6[.git/hooks/post-rewrite]}" 			-a -n "${F6[.git/hooks/pre-commit]}" \
    -a "${A3_VERSION_TEXT}" == "${A6_VERSION_TEXT}"	-a "${A3_VERSION_SHA_LONG}" == "${A6_VERSION_SHA_LONG}" \
] || MSG="$MSG; Bad prepare v0.0.27"

[ \
       "10" == "${#F6[@]}"           				-a "0" == "${#C6[@]}" \
    -a -n "${F6[README.txt]}"       				-a -n "${F6[.gitattributes]}" \
    -a -n "${F6[.version-stamper]}" 				-a -n "${F6[ver.sh]}" \
    -a -n "${F6[.git/]}"     						-a -n "${F6[.git/hooks/post-checkout]}" \
    -a -n "${F6[.git/hooks/post-commit]}" 			-a -n "${F6[.git/hooks/post-merge]}" \
    -a -n "${F6[.git/hooks/post-rewrite]}" 			-a -n "${F6[.git/hooks/pre-commit]}" \
    -a "${A4_VERSION_TEXT}" == "${A7_VERSION_TEXT}"	-a "${A4_VERSION_SHA_LONG}" != "${A7_VERSION_SHA_LONG}" \
] || MSG="$MSG; Bad squash v0.0.28"


if [ -z "$MSG" ]; then
    echo "[ OK ]  $0     Merge squash OK"
else
    echo "[FAIL]  $0     ${MSG#; }"
fi

git reset --hard origin/MASTER >/dev/null
CLEAN_HOOKS .git
CLEAN_WORKTREE .

popd >/dev/null 2>&1
