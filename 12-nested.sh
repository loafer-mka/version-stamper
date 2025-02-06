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


[ -d "./temp/.git" ] && rm -rf ./temp/

GIT_INIT temp >/dev/null

CLEAN_HOOKS temp/.git
CLEAN_WORKTREE temp

[ -d "temp/foo/bar" ] || mkdir -p temp/foo/bar

cd temp

../../../version-stamper -cd foo/bar --config

# all plugins gitignore, all hooks
sed -i -r \
	-e 's/^\s*#\s*plugin-SH:.*$/plugin-SH: --gitignore --gitattributes ver.sh/' \
	-e 's/^\s*#\s*leader:.*$/leader: T12_/' \
	${WIN_SED_EOL} \
	foo/bar/.version-stamper

text="$(find . |grep -v -E '^(\./\.git/hooks/[[:alnum:]_+-]+.sample|\./\.git/objects/[0-9a-fA-F/]+)$' |sort --ignore-nonprinting --ignore-case --dictionary-order)"
#echo "'${text}'"

[ "${text}" == ".
./foo
./foo/bar
./foo/bar/.gitattributes
./foo/bar/.version-stamper
./.git
./.git/branches
./.git/config
./.git/description
./.git/HEAD
./.git/hooks
./.git/index
./.git/info
./.git/info/exclude
./.git/objects
./.git/objects/info
./.git/objects/pack
./.git/refs
./.git/refs/heads
./.git/refs/tags" ] || DIE 1 "[FAIL]  $0     Mismatch files after --config and --setup"

git --no-pager add . >/dev/null 2>&1
git commit -am "Initial commit" >/dev/null 2>&1
# no installed hooks here

text="$(find . |grep -v -E '^(\./\.git/hooks/[[:alnum:]_+-]+.sample|\./\.git/objects/[0-9a-fA-F/]+)$' |sort --ignore-nonprinting --ignore-case --dictionary-order)"
#echo "'${text}'"

[ "${text}" == ".
./foo
./foo/bar
./foo/bar/.gitattributes
./foo/bar/.version-stamper
./.git
./.git/branches
./.git/COMMIT_EDITMSG
./.git/config
./.git/description
./.git/HEAD
./.git/hooks
./.git/index
./.git/info
./.git/info/exclude
./.git/logs
./.git/logs/HEAD
./.git/logs/refs
./.git/logs/refs/heads
./.git/logs/refs/heads/MASTER
./.git/objects
./.git/objects/info
./.git/objects/pack
./.git/refs
./.git/refs/heads
./.git/refs/heads/MASTER
./.git/refs/tags" ] || DIE 1 "[FAIL]  $0     Mismatch files after git commit"


../../../version-stamper -cd foo/bar --generate
[ -f foo/bar/ver.sh ] && source foo/bar/ver.sh

text="$(find . |grep -v -E '^(\./\.git/hooks/[[:alnum:]_+-]+.sample|\./\.git/objects/[0-9a-fA-F/]+)$' |sort --ignore-nonprinting --ignore-case --dictionary-order)"
#echo "'${text}'"

[ "${text}" == ".
./foo
./foo/bar
./foo/bar/.gitattributes
./foo/bar/.gitignore
./foo/bar/ver.sh
./foo/bar/.version-stamper
./.git
./.git/branches
./.git/COMMIT_EDITMSG
./.git/config
./.git/description
./.git/HEAD
./.git/hooks
./.git/index
./.git/info
./.git/info/exclude
./.git/logs
./.git/logs/HEAD
./.git/logs/refs
./.git/logs/refs/heads
./.git/logs/refs/heads/MASTER
./.git/objects
./.git/objects/info
./.git/objects/pack
./.git/refs
./.git/refs/heads
./.git/refs/heads/MASTER
./.git/refs/tags" \
	-a -n "$(grep -E "^ver\.sh\s+" foo/bar/.gitattributes)" \
	-a -n "$(grep -E "^ver\.sh$" foo/bar/.gitignore)" \
] || DIE 1 "[FAIL]  $0     Mismatch files after generate"

[ \
	   "${T12_VERSION_ID}" == "0x00000001" \
	-a "${T12_VERSION_TEXT}" == "v0.0.1-MASTER" \
	-a "${T12_VERSION_BRANCH}" == "MASTER" \
] || DIE 1 "[FAIL]  $0     Bad version data after generate"

echo "[ OK ]  $0     Nested pathes OK"

popd >/dev/null 2>&1
