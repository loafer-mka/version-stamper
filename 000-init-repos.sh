#!/bin/bash

# +--------------------------------------------------------------------+
# | This Source Code Form is subject to the terms of the Mozilla       |
# | Public License, v. 2.0. If a copy of the MPL was not distributed   |
# | with this file, You can obtain one at http://mozilla.org/MPL/2.0/. |
# +--------------------------------------------------------------------+
#        email: Andrey Makarov <mka-at-mailru@mail.ru>
# Project home: https://github.com/loafer-mka/version-stamper.git
#
#               Copyright (c) Andrey Makarov 2023-2026

if [ -z "${DELIM_ROW}" ]; then
    source "$(dirname "$0")/lib.sh"
fi

pushd "$(dirname "$0")" >/dev/null

[ -d "./repos" ] || mkdir -p "./repos"

[ -d "./repos/bare0.git" ] && rm -rf "./repos/bare0.git"
[ -d "./repos/bare1.git" ] && rm -rf "./repos/bare1.git"
[ -d "./repos/contrib" ] && rm -rf "./repos/contrib"
[ -d "./repos/fresh" ] && rm -rf "./repos/fresh"
[ -d "./repos/detach-f" ] && rm -rf "./repos/detach-f"
[ -d "./repos/detach-p" ] && rm -rf "./repos/detach-p"
[ -d "./repos/clone-a" ] && rm -rf "./repos/clone-a"
[ -d "./repos/clone-e" ] && rm -rf "./repos/clone-e"
[ -d "./repos/clone-m" ] && rm -rf "./repos/clone-m"
[ -d "./repos/clone-x" ] && rm -rf "./repos/clone-x"
[ -d "./repos/clone-x.git" ] && rm -rf "./repos/clone-x.git"
[ -d "./repos/worktree" ] && rm -rf "./repos/worktree"
[ -d "./repos/customdir" ] && rm -rf "./repos/customdir"

#
# create two bare repo:
#   bare0.git   <- contains full set of commits
#   bare1.git   <- contains short subset of bare0.git commits
#                  (this is quick and simple way to create two bare repo)
#
echo "> git init --bare \"./repos/bare0.git\""
GIT_INIT "./repos/bare0.git" --bare

echo "> git init --bare \"./repos/bare1.git\""
GIT_INIT "./repos/bare1.git" --bare

#
# create two working repo
#   fresh       <- contains no data yet; git init only; no commits, no remotes.
#   contrib     <- main working repo, linked to both remotes bare0.git and bare1.git
#       we will store data, create branches, submodules, worktrees here
#       and push them into remotes;
#		last commit at SUBMOD branch
# clone-* clones of bare0.git in different states
#   clone-a     <- clone of master branch, no submodules
#   clone-e     <- non-recusive clone of SUBMOD branch                      TODO: re-clone before test, because stamper updates submodules
#   clone-m     <- recursive clone of SUBMOD branch
#	clone-x		<- clone of bare1.git branch F with seprate git directory
#	clone-x.git	<- seprate git directory of 'clone-x'
# detach-* clones of bare1.git with detached head
#   detach-f    <- we make few commits after detach, so HEAD position is in 'future' relative branch head
#   detach-p    <- we detach head and move it below, so it is in 'past' relative branch head
# worktree another branch of contrib repo
#	worktree	<- the SUBMOD0 branch of contrib
#
echo "> git init \"./repos/fresh\""
GIT_INIT "./repos/fresh"

echo "> git init \"./repos/contrib\""
GIT_INIT "./repos/contrib"

echo "> pushd \"./repos/contrib\""
pushd "./repos/contrib" >/dev/null

#
# NOTE: we use strange remotes and branch names; it might confuse people... and git.
# so we use remotes 'ORIGIN/ONE' and 'ORIGIN' (with slash)
# also we use branch names with slashes, so
# remote 'ORIGIN' with branch 'ONE/N' will be stored as '.git/refs/remotes/ORIGIN/ONE/N'
# and other
# remote 'ORIGIN/ONE' with branch 'N' will be stored as '.git/refs/remotes/ORIGIN/ONE/N'
# identical head placement for different remotes and branches ... yes, this is git
#
echo "> git remote add 'ORIGIN/ONE' ../bare0.git"
git --no-pager remote add 'ORIGIN/ONE' ../bare0.git
echo "> git remote add 'ORIGIN' ../bare1.git"
git --no-pager remote add 'ORIGIN' ../bare1.git

echo "> git fetch --all"
git --no-pager fetch --all

#
# create structure
#   small letters - commit designator (based on added into README.txt text)
#   caps - branch/tag name
#
#                             +-f1--f2--f3--f4--f5--F
#                            /                    \
#                           /                      +-f5+k2:1--f5+k2:2--F5
#                          /                      /
#                         /                +-k1--k2--k3--k4--k5--K
#                        /                /
#                       /                /                     +-SUBMOD0--SUBMOD
#                      /                /                     /
#                     /                /      +-m/m1--m/m2--m/m3--m/m4--m/m5--M/M
#                    /                /      /
#                   /                /      /                              +-u1--u2--u3--u4--u5--U
#                  /                /      /                              /
# A0--b--c--d--e--F0--g--h--I0--j--K0--l--M0--ONE/N0--o--P0--q--r--s--t--U0--v--w--x--y--MASTER
#                            \                  \         \
#                             \                  \         +-p1--p2--p3--p4--p5--P
#                              \                  \
#                               \                  +-one/n1--one/n2--one/n3--one/n4--one/n5--ONE/N
#                                \
#                                 +-i/i1--i/i2--i/i3--i/i4--i/i5--I/I
#
#
# |   local   | ORIGIN/ONE |  ORIGIN  |
# +-----------+------------+----------+
# |    A0     |     A0     |          |
# |    F0     |            |          |
# |    F      |     F      |     F    |
# |    F5     |            |          |
# |    I0     |            |          |
# |   I/I     |    I/I     |          |
# |    K0     |            |          |
# |    K      |     K      |          |
# |    M0     |            |          |
# |   M/M     |    M/M     |          |
# |  MASTER   |   MASTER   |          |
# |  ONE/N0   |            |          |
# |   ONE/N   |     N      |  ONE/N   |
# |    P0     |            |          |
# |    P      |     P      |          |
# |    U0     |            |          |
# |    U      |            |          |
# |  SUBMOD0  |   SUBMOD0  |          |
# |  SUBMOD   |   SUBMOD   |          |
# +-----------+------------+----------+
#
# all brancehs except 'SUBMOD0' and 'SUBMOD' are "simple" - i.e. we did add one line to README.txt per each commit.
# SUBMOD0 - 4 submodules were added:
#   ./sub0  at branch U0 from ORIGIN/ONE
#   ./sub1  at branch U from ORIGIN/ONE
#   ./sub2  at branch ONE/N from ORIGIN
#   ./sub3  at branch F from ORIGIN
#   ./sub0w worktree of ./sub0/.git at branch F (from ORIGIN/ONE as ./sub0)
# SUBMOD - added 1 submodule with submodules
#   ./subM  at branch SUBMOD from ORIGIN/ONE
#
M="Initial"
echo "> rm README.txt"
rm README.txt 2>/dev/null
N=1
echo -e ".gitattributes  text eol=lf\n.gitignore  text eol=lf\n.gitmodules  text eol=lf\n*.txt  text" >.gitattributes
echo "> git add  .gitattributes"
git --no-pager add .gitattributes
for A in A B C D E F G H I J K L M N O P Q R S T U V W X Y Z ; do
    echo "${A}${WIN_ECHO_EOL}" >>README.txt
    echo "> git add  README.txt"
    git --no-pager add README.txt
    echo "> git commit -m \"${A} : ${M} commit\""
    git --no-pager commit -m "${A} : ${M} commit"
    sleep 1s
    case "${A}" in
    A)
        echo "> git branch -- \"${A}0\""
        git --no-pager branch -- "${A}0"
        ;;
    F | K | P | U)
        echo "> git branch -- \"${A}0\""
        git --no-pager branch -- "${A}0"
        echo "> git branch -- \"${A}\""
        git --no-pager branch -- "${A}"
        ;;
    I | M)
        echo "> git branch -- \"${A}/${A}0\""
        git --no-pager branch -- "${A}0"
        echo "> git branch -- \"${A}/${A}\""
        git --no-pager branch -- "${A}/${A}"
        ;;
    N)
        echo "> git branch -- \"ONE/${A}0\""
        git --no-pager branch -- "ONE/${A}0"
        echo "> git branch -- \"ONE/${A}\""
        git --no-pager branch -- "ONE/${A}"
        ;;
    *)
        ;;
    esac
    M="#${N}"
    ((N++))
done

for B in F K P U "I/I" "M/M" "ONE/N"; do
    echo "> git checkout \"${B}\""
    git --no-pager checkout "${B}"
    for N in 1 2 3 4 5 6; do
        echo "${B}${N}${WIN_ECHO_EOL}" >>README.txt
        echo "> git commit -am \"${B}${N} commit\""
        git --no-pager commit -am "${B}${N} commit"
        sleep 1s
    done
done

echo "> git --no-pager checkout -B F5 F^"
git --no-pager checkout -B F5 F^
echo "> git --no-pager merge --no-commit -s ours K^^^^"
git --no-pager merge --no-commit -s ours K^^^^
echo "Merge with 'K2' commit using ours strategy${WIN_ECHO_EOL}" >>README.txt
echo "> git --no-pager commit -am \"F5+K2 merge commits\""
git --no-pager commit -am "F5+K2 merge commits"
for N in 1 2 3; do
	echo "F5+K2:${N}${WIN_ECHO_EOL}" >>README.txt
	echo "> git commit -am \"F5+K2:${N} commit\""
	git --no-pager commit -am "F5+K2:${N} commit"
	sleep 1s
done

echo "> git checkout MASTER"
git --no-pager checkout MASTER

# echo "> git gc"
# git gc
# do not use garbage collector -- many local referencies goes into packed
# refs -> it is not too easy to look by eyes in files and folders

for B in A0 F K P U "I/I" "M/M" "MASTER" ; do
    echo "> git push \"ORIGIN/ONE\" \"${B}:${B}\""
    git --no-pager push "ORIGIN/ONE" "${B}:${B}"
done

for B in F "ONE/N" ; do
    echo "> git push \"ORIGIN\" \"${B}:${B}\""
    git --no-pager push "ORIGIN" "${B}:${B}"
done

echo "> git push \"ORIGIN/ONE\" \"U0:U0\""
git --no-pager push "ORIGIN/ONE" "U0:U0"
# the "ORIGIN/ONE"/"N" branch has same refname as "ORIGIN"/"ONE/N" ...
echo "> git push \"ORIGIN/ONE\" \"ONE/N:N\""
git --no-pager push "ORIGIN/ONE" "ONE/N:N"
echo "> git fetch --all"
git --no-pager fetch --all

# --- add submodules ---
echo "> git checkout -B SUBMOD0 M/M^^^"
git --no-pager checkout -B SUBMOD0 M/M^^^
echo "> git submodule add -b U --name ORIGIN_ONE-U -- ../bare0.git ./sub1"
git --no-pager submodule add -b U --name ORIGIN_ONE-U -- ../bare0.git ./sub1
echo "> git submodule add -b U0 --name ORIGIN_ONE-U0 -- ../bare0.git ./sub0"
git --no-pager submodule add -b U0 --name ORIGIN_ONE-U0 -- ../bare0.git ./sub0
echo "> git submodule add -b one/N --name ORIGIN-ONE_N -- ../bare1.git ./sub2"
git --no-pager submodule add -b ONE/N --name ORIGIN-ONE_N -- ../bare1.git ./sub2
echo "> git submodule add -b F --name ORIGIN-F -- ../bare1.git ./sub3"
git --no-pager submodule add -b F --name ORIGIN-F -- ../bare1.git ./sub3

echo "> git add .gitmodules"
git --no-pager add .gitmodules
echo "Add submodules${WIN_ECHO_EOL}" >>README.txt
echo "> git commit -am \"Add submodules\""
git --no-pager commit -am "Add submodules"
echo "> git push \"ORIGIN/ONE\" \"SUBMOD0:SUBMOD0\""
git --no-pager push "ORIGIN/ONE" "SUBMOD0:SUBMOD0"

# --- add workree ---
echo "> pushd ./sub0"
pushd ./sub0 >/dev/null
echo "> git worktree add ../sub0w F"
git --no-pager worktree add ../sub0w F
echo "> popd"
popd >/dev/null
# worktrees as submodules are not supported, so ignore it
echo "sub0w" >>.gitignore
echo "> git add .gitignore"
git --no-pager add .gitignore

# --- add submod with submodules ---
echo "> git submodule add --branch SUBMOD0 --name ORIGIN_ONE-SUBMOD0 -- ../bare0.git ./subM"
git --no-pager submodule add --branch SUBMOD0 --name ORIGIN_ONE-SUBMOD0 -- ../bare0.git ./subM
echo "> git checkout -B SUBMOD"
git --no-pager checkout -B SUBMOD
echo "Add submodule's worktree and submodule with submodules${WIN_ECHO_EOL}" >>README.txt
echo "> git commit -am \"Add submodule with submodules\""
git --no-pager commit -am "Add submodule with submodules"
echo "> git push \"ORIGIN/ONE\" \"SUBMOD:SUBMOD\""
git --no-pager push "ORIGIN/ONE" "SUBMOD:SUBMOD"

echo "> git log --graph --oneline --all"
git --no-pager log --graph --oneline --all
echo "> git branch --all --verbose"
git --no-pager branch --all --verbose

# --- add worktree with submodules ---
echo "> git --no-pager worktree add ../worktree SUBMOD0"
git --no-pager worktree add ../worktree SUBMOD0

echo "> popd"
popd >/dev/null

# --- create clones ---
echo "> git clone --branch MASTER ./repos/bare0.git ./repos/clone-a"
git --no-pager clone --branch MASTER ./repos/bare0.git ./repos/clone-a

echo "> git clone --branch SUBMOD ./repos/bare0.git ./repos/clone-e"
git --no-pager clone --branch SUBMOD ./repos/bare0.git ./repos/clone-e

echo "> git clone --branch SUBMOD --recurse-submodules ./repos/bare0.git ./repos/clone-m"
git --no-pager clone --branch SUBMOD --recurse-submodules ./repos/bare0.git ./repos/clone-m

echo "> git clone --branch F ./repos/bare1.git --branch F --separate-git-dir=./repos/clone-x.git ./repos/clone-x"
git --no-pager clone --branch F ./repos/bare1.git --branch F --separate-git-dir=./repos/clone-x.git ./repos/clone-x

# --- detached 'in future' ---
# detached head above branch label (in future)
# extra non-version tags were added
echo "> git clone --branch F ./repos/bare1.git ./repos/detach-f"
git --no-pager clone --branch F ./repos/bare1.git ./repos/detach-f
echo "> pushd ./repos/detach-f"
pushd ./repos/detach-f >/dev/null
echo "> git checkout \$(git --no-pager rev-parse F)"
git --no-pager -c advice.detachedHead=false checkout $(git --no-pager rev-parse F)
for n in 1 2 3 4 5 ; do
    echo "Detach ${n}${WIN_ECHO_EOL}" >>README.txt
    echo "> git commit -am 'Detach ${n}'"
    git --no-pager commit -am "Detach ${n}"
    sleep 1s
done
echo "> git tag TAG-2 HEAD^^"
git --no-pager tag TAG-2 HEAD^^
echo "> git tag TAG-1 F^^"
git --no-pager tag TAG-1 F^^
echo "> git tag X1.2 F^^^^^^^^"
git --no-pager tag X1.2 F^^^^^^^^
echo "> popd"
popd >/dev/null

# --- detached 'in past' ---
# detached head below branch label (in past)
# extra non-version tags were added
echo "> git clone --branch F ./repos/bare1.git ./repos/detach-p"
git --no-pager clone --branch F ./repos/bare1.git ./repos/detach-p
echo "> pushd ./repos/detach-p"
pushd ./repos/detach-p >/dev/null
echo "> git checkout \$(git --no-pager rev-parse F)"
git --no-pager -c advice.detachedHead=false checkout $(git --no-pager rev-parse F)
for n in 1 2 3 4 5 ; do
    echo "Detach ${n}${WIN_ECHO_EOL}" >>README.txt
    echo "> git commit -am 'Detach ${n}'"
    git --no-pager commit -am "Detach ${n}"
    sleep 1s
done
echo "> git tag TAG-3 HEAD"
git --no-pager tag TAG-3 HEAD
echo "> git tag TAG-2 HEAD^^"
git --no-pager tag TAG-2 HEAD^^
echo "> git tag TAG-1 F^^^^"
git --no-pager tag TAG-1 F^^^^
echo "> git checkout \$(git --no-pager rev-parse F^^)"
git --no-pager -c advice.detachedHead=false checkout $(git --no-pager rev-parse F^^)
echo "> git tag X1.2 HEAD^^^^"
git --no-pager tag X1.2 HEAD^^^^
echo "> popd"
popd >/dev/null

# --- with custom plugins and textoize scripts ---
echo "> git clone --branch F ./repos/bare1.git ./repos/customdir"
git --no-pager clone --filter=tree:0 --single-branch --branch F ./repos/bare1.git ./repos/customdir
echo "> pushd ./repos/customdir"
pushd ./repos/customdir >/dev/null
echo "> git tag x1.1 HEAD^^"
git --no-pager tag x1.1 HEAD^^
echo "> git tag v0.5 HEAD^^^^^"
git --no-pager tag v0.5 HEAD^^^^^
echo "> git tag v0.0 F^^^^^^^^^"
git --no-pager tag v0.0 F^^^^^^^^^
echo "> git checkout \$(git --no-pager rev-parse F^^)"
echo "create .version-stamper"
echo "
#
#   o p t i o n s
#
# verbose mode
#verbose:         false
#
# abbreviation length
# if not set, assumes 8 characters
#abbrev:          8
#
# leading text before version identifier; for example VERSION_TEXT becomes LEADER_VERSION_TEXT
leader:          CUSTOM_
#
# trailing text after version identifier; for example VERSION_TEXT becomes VERSION_TEXT_TRAILER
trailer:         _DIR
#
# the company/person title
# if not set, then used:
# a) under Windows - 'HKLM\Software\Microsoft\WIndows NT\registered organization';
# b) under Linux - username;
# c) otherwise 'Unknown Author' will be assumed.
authorship:       Andrey Makarov
#
# the copyright/copyleft declaration
# if not set, then used \"\${DEFAULT_DECL} (c) AUTHORSHIP YEAR\" were:
#    DEFAULT_DECL is set by the 'STAMPER_DEFAULT_DECL' parameter of the file ./version-stamper-config;
#    AUTHORSHIP is specified by the 'authorship:' parameter above;
#    YEAR is the current year or year of initial commit.
declaration: Copyright (c) Andrey Makarov 2022-2026
#
# activate hooks
# available hooks are:  pre-commit  post-commit  post-checkout  post-rewrite  post-merge
# if not set, then will be used:  pre-commit  post-checkout  post-rewrite  post-merge  (all but post-commit)
#hooks:           pre-commit post-commit post-checkout post-rewrite post-merge
hooks:          version-stamper pre-commit post-checkout post-rewrite post-merge
# note 1: if pre-commit is used then post-commit is useless
# note 2: the 'version-stamper' hook is very special, for given self-containig repo only
#         this affects on reloading version data after hooks upgrade
#
# the default command
# it will be used if stamper is running without argumentss (if not set, --help is ssumed)
default-cmd:     --list
#
# custom folder
# additional folder to search plugins and textoize scripts
# absolute or .version-stamper - relative path; this option must be before
# 'textoize' and 'plugin-...' options.
custom-dir: CUSTOM
#
# the version textoize script
# it will be used to build VERSION_TEXT using other VERSION_* variables
# if not set, then use hardcoded v0.0.0-branch+ form, otherwise you may choose
# one of 'default' 'alt'
textoize:        XXX

#   p l u g i n s
#
# path to version target file which will created or updated by given plugin
#plugin-BAT:      ./samples/sample-BAT.bat
#plugin-C:        ./samples/sample-C.h
#plugin-CMAKE:    ./samples/sample-CMAKE.cmake
#plugin-CS:       ./samples/sample-AssemblyInfo.cs
#plugin-INFO:     ./samples/sample-INFO.txt
#plugin-M:        ./samples/sample-M.m
#plugin-MAKEFILE: ./samples/sample-MAKEFILE.mk
#plugin-MARKDOWN: ./samples/sample-MARKDOWN.md
#plugin-SH:       ./samples/sample-SH.sh
#plugin-SH:       ./version-stamper-this
plugin-XXX:       ./version.XXX

#   t h e   e n d
" >.version-stamper
echo "mkdir -- CUSTOM"
mkdir -- CUSTOM
echo "create version-stamper-textoize-XXX"
echo "
   printf -v VERSION_ID '0x%08X' \$((0x\$VERSION_ID+0x11100))
   VERSION_TEXT=\"_\${VERSION_TEXT}_\"
   VERSION_PREFIX=_\${VERSION_PREFIX}_
   VERSION_MAJOR=\$((\$VERSION_MAJOR+0))
   VERSION_MINOR=\$((\$VERSION_MINOR+1))
   VERSION_SUFFIX=\"#\$VERSION_SUFFIX\"
   VERSION_BUILD=\$((\$VERSION_BUILD+0x1100))
   VERSION_BRANCH=\"_\${VERSION_BRANCH}_\"
   VERSION_DIRTY=\"\${VERSION_DIRTY:--}\"
   VERSION_DATE=\"1024-01-01 00:00:00\"
   VERSION_SHORTDATE=240101000000
   VERSION_UNIXTIME=-29852937017
   VERSION_SHA_LONG=1111111111111111111111111111111111111111
   VERSION_SHA_SHORT=11111111
   VERSION_HOSTINFO=\"xxx@yyy.zzz test system\"
   VERSION_AUTHORSHIP=\"XXX YYY\"
   VERSION_DECLARATION=\"Copyright (c) XXX YYY 2022\"
   VERSION_SUBMOD_NAME=unknown
   VERSION_SUBMOD_PATH=unknown
   VERSION_COMMIT_AUTHOR=\"XXX YYY\"
   VERSION_COMMIT_EMAIL=xxx@yyy.zzz
" >CUSTOM/version-stamper-textoize-XXX
echo "create version-stamper-plugin-XXX"
echo "
function __PLUGIN_XXX_NOTICE__
{
	echo \"   plugin-XXX        Shell script; eol=CR+LF\"
}

function __PLUGIN_XXX_SAMPLE__
{
	echo \"#plugin-XXX:      --gitignore  version.xxx\"
}

function __PLUGIN_XXX_ATTRIB__
{
	echo \"text eol=lf\"
}

function __PLUGIN_XXX_GETVER__
{
	# note: use strong name compare (${NAME_VERSION_TEXT} rather than \w*VERSION_TEXT\w*)
	# so changing version or changing leader/trailer must lead to rewrite target file.
	sed --binary --regexp-extended --silent \\
		-e \"s/^\\s*\${NAME_VERSION_TEXT}\\s+\\\"(.*)\\\".*\$/\\\\1/p\"
}

function __PLUGIN_XXX_CREATE__
{
	__STORE_LF__ \"\$1\" <<-END_OF_TEXT
	\${NAME_VERSION_ID}              \"\${VERSION_ID}\"
	\${NAME_VERSION_TEXT}            \"\${VERSION_TEXT_QUOTED}\"
	\${NAME_VERSION_DATE}            \"\${VERSION_DATE_QUOTED}\"
	\${NAME_VERSION_SHORTDATE}       \"\${VERSION_SHORTDATE}\"
	\${NAME_VERSION_UNIXTIME}        \"\${VERSION_UNIXTIME}\"
	\${NAME_VERSION_BRANCH}          \"\${VERSION_BRANCH_QUOTED}\"
	\${NAME_VERSION_DIRTY}           \"\${VERSION_DIRTY}\"
	\${NAME_VERSION_HOSTINFO}        \"\${VERSION_HOSTINFO_QUOTED}\"
	\${NAME_VERSION_AUTHORSHIP}      \"\${VERSION_AUTHORSHIP_QUOTED}\"
	\${NAME_VERSION_DECLARATION}     \"\${VERSION_DECLARATION_QUOTED}\"
	\${NAME_VERSION_COMMIT_AUTHOR}   \"\${VERSION_COMMIT_AUTHOR_QUOTED}\"
	\${NAME_VERSION_COMMIT_EMAIL}    \"\${VERSION_COMMIT_EMAIL_QUOTED}\"
	\${NAME_VERSION_SHA_SHORT}       \"\${VERSION_SHA_SHORT}\"
	\${NAME_VERSION_SHA_LONG}        \"\${VERSION_SHA_LONG}\"
END_OF_TEXT
}

function __PLUGIN_XXX_MODIFY__
{
	sed --binary --regexp-extended \\
		-e \"s/^(\\s*)(\\w*VERSION_ID\\w*)(\\s+)(\\\".*\\\")(.*)\$/\\\\1\${NAME_VERSION_ID}\\\\3\${VERSION_ID}\\\\5/\" \\
		-e \"s/^(\\s*)(\\w*VERSION_TEXT\\w*)(\\s+)(\\\".*\\\")(.*)\$/\\\\1\${NAME_VERSION_TEXT}\\\\3\\\"\${VERSION_TEXT_RQREG}\\\"\\\\5/\" \\
		-e \"s/^(\\s*)(\\w*VERSION_DATE\\w*)(\\s+)(\\\".*\\\")(.*)\$/\\1\${NAME_VERSION_DATE}\\\\3\\\"\${VERSION_DATE_RQREG}\\\"\\\\5/\" \\
		-e \"s/^(\\s*)(\\w*VERSION_SHORTDATE\\w*)(\\s+)(\\\".*\\\")(.*)\$/\\1\${NAME_VERSION_SHORTDATE}\\\\3\\\"\${VERSION_SHORTDATE}\\\"\\\\5/\" \\
		-e \"s/^(\\s*)(\\w*VERSION_UNIXTIME\\w*)(\\s+)(\\\".*\\\")(.*)$/\\1\${NAME_VERSION_UNIXTIME}\\\\3\\\"\${VERSION_UNIXTIME}\\\"\\\\5/\" \\
		-e \"s/^(\\s*)(\\w*VERSION_BRANCH\\w*)(\\s+)(\\\".*\\\")(.*)$/\\1\${NAME_VERSION_BRANCH}\\\\3\\\"\${VERSION_BRANCH_RQREG}\\\"\\\\5/\" \\
		-e \"s/^(\\s*)(\\w*VERSION_DIRTY\\w*)(\\s+)(\\\".*\\\")(.*)$/\\1\${NAME_VERSION_DIRTY}\\\\3\\\"\${VERSION_DIRTY}\\\"\\\\5/\" \\
		-e \"s/^(\\s*)(\\w*VERSION_HOSTINFO\\w*)(\\s+)(\\\".*\\\")(.*)$/\\1\${NAME_VERSION_HOSTINFO}\\\\3\\\"\${VERSION_HOSTINFO_RQREG}\\\"\\\\5/\" \\
		-e \"s/^(\\s*)(\\w*VERSION_AUTHORSHIP\\w*)(\\s+)(\\\".*\\\")(.*)$/\\1\${NAME_VERSION_AUTHORSHIP}\\\\3\\\"\${VERSION_AUTHORSHIP_RQREG}\\\"\\\\5/\" \\
		-e \"s/^(\\s*)(\\w*VERSION_DECLARATION\\w*)(\\s+)(\\\".*\\\")(.*)$/\\1\${NAME_VERSION_DECLARATION}\\\\3\\\"\${VERSION_DECLARATION_RQREG}\\\"\\\\5/\" \\
		-e \"s/^(\\s*)(\\w*VERSION_COMMIT_AUTHOR\\w*)(\\s*)(\\\".*\\\")(.*)$/\\1\${NAME_VERSION_COMMIT_AUTHOR}\\\\3\\\"\${VERSION_COMMIT_AUTHOR_RQREG}\\\"\\\\5/\" \\
		-e \"s/^(\\s*)(\\w*VERSION_COMMIT_EMAIL\\w*)(\\s*)(\\\".*\\\")(.*)$/\\1\${NAME_VERSION_COMMIT_EMAIL}\\\\3\\\"\${VERSION_COMMIT_EMAIL_RQREG}\\\"\\\\5/\" \\
		-e \"s/^(\\s*)(\\w*VERSION_SHA_SHORT\\w*)(\\s+)(\\\".*\\\")(.*)$/\\1\${NAME_VERSION_SHA_SHORT}\\\\3\\\"\${VERSION_SHA_SHORT}\\\"\\\\5/\" \\
		-e \"s/^(\\s*)(\\w*VERSION_SHA_LONG\\w*)(\\s+)(\\\".*\\\")(.*)$/\\1\${NAME_VERSION_SHA_LONG}\\\\3\\\"\${VERSION_SHA_LONG}\\\"\\\\5/\" \\
	| __STORE_LF__ \"\$1\"
}
" >CUSTOM/version-stamper-plugin-XXX
echo "git add ."
git add .
echo "git commit -m \"Add custom-dir\""
git commit -m "Add custom-dir"
echo "> popd"
popd >/dev/null

echo "> popd (final)"
popd >/dev/null
