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

[ -d "./temp/.git" ] && rm -rf ./temp/

GIT_INIT temp >/dev/null

CLEAN_HOOKS temp/.git
CLEAN_WORKTREE temp

cd temp

../../../version-stamper -c

# all plugins gitignore, all hooks
sed -i -r -e 's/^\s*#\s*plugin-C:.*$/plugin-C: --gitignore ver.h/' \
	 -e 's/^\s*#\s*plugin-CS:.*$/plugin-CS: --gitignore ver.cs/' \
	 -e 's/^\s*#\s*plugin-BAT:.*$/plugin-BAT: --gitignore ver.bat/' \
	 -e 's/^\s*#\s*plugin-SH:.*$/plugin-SH: --gitignore ver.sh/' \
	 -e 's/^\s*#\s*plugin-MAKEFILE:.*$/plugin-MAKEFILE: --gitignore ver.mk/' \
	 -e 's/^\s*(#\s*)?hooks:.*$/hooks: pre-commit  post-commit  post-checkout  post-rewrite  post-merge/' \
	 -e 's/^\s*(#\s*)?abbrev:.*$/abbrev: 9/' \
	 ${WIN_SED_EOL} \
	.version-stamper

../../../version-stamper -g 2>/dev/null

source ver.sh

#for v in ${!VERSION@}; do declare -n z=$v; echo "$v = \"$z\""; done
#ls -la .git/hooks

[ \
	   "0x00000000" == "${VERSION}" \
	-a "v0.0-0.MASTER+" == "${VERSION_TEXT}" \
	-a "MASTER+" == "${VERSION_BRANCH}" \
	-a "0000000000000000000000000000000000000000" == "${VERSION_SHA}" \
	-a "000000000" == "${VERSION_SHA_ABBREV}" \
] || DIE 1 "[FAIL]  $0     Version information is wrong"

[ \
     -f .git/hooks/pre-commit           -a -f .git/hooks/post-checkout \
  -a -f .git/hooks/post-commit          -a -f .git/hooks/post-rewrite \
  -a -f .git/hooks/post-merge           -a ! -f .git/hooks/prepare-commit-msg \
  -a ! -f .git/hooks/commit-msg         -a ! -f .git/hooks/applypatch-msg \
  -a ! -f .git/hooks/pre-applypatch     -a ! -f .git/hooks/post-applypatch \
  -a ! -f .git/hooks/pre-rebase         -a ! -f .git/hooks/pre-push \
  -a ! -f .git/hooks/pre-auto-gc        -a ! -f .git/hooks/pre-receive \
  -a ! -f .git/hooks/update             -a ! -f .git/hooks/post-receive \
  -a ! -f .git/hooks/fsmonitor-watchman -a ! -f .git/hooks/post-update \
] || DIE 1 "[FAIL]     $0   WANTED HOOKS SET"

echo "[ OK ]  $0     Version data for fresh repo"

unset ${!VERSION@}

echo "test 1${WIN_ECHO_EOL}" >TEST.txt
git --no-pager add TEST.txt >/dev/null 2>&1
sed -i -r \
	-e 's/^\s*(#\s*?)verbose:.*$/verbose: true/' ${WIN_SED_EOL} \
	.version-stamper
sed -i -r \
	-e 's/^\s*export\s+STAMPER_SUITE\s*=.*$/export STAMPER_SUITE="Version suite v0.0-0.nobranch"/' \
	.git/hooks/post-commit
sed -i -r \
	-e 's/^\s*export\s+STAMPER_SUITE\s*=.*$/export STAMPER_SUITE="Version suite v0.0-0.nobranch"/' \
	.git/hooks/pre-commit
echo -e "#!/bin/bash\n\nexport STAMPER_SUITE=\"Version suite v0.0-0.nobranch\"\n" >.git/hooks/pre-receive
chmod a+x .git/hooks/pre-receive

git commit -am "First commit" >/dev/null 2>&1
#git commit -am "First commit"

source ver.sh

#for v in ${!VERSION@}; do declare -n z=$v; echo "$v = \"$z\""; done
#ls -la .git/hooks

# note: version stamps must be done by pre-commit hook, so parent's SHA must be used (p:0000...)
[ \
	   "0x00000001" == "${VERSION}" \
	-a "v0.0-1.MASTER" == "${VERSION_TEXT}" \
	-a "MASTER" == "${VERSION_BRANCH}" \
	-a "p:0000000000000000000000000000000000000000" == "${VERSION_SHA}" \
	-a "p:000000000" == "${VERSION_SHA_ABBREV}" \
] || DIE 1 "[FAIL]  $0     Version information is wrong"

[ \
     -f .git/hooks/pre-commit           -a -f .git/hooks/post-checkout \
  -a -f .git/hooks/post-commit          -a -f .git/hooks/post-rewrite \
  -a -f .git/hooks/post-merge           -a ! -f .git/hooks/prepare-commit-msg \
  -a ! -f .git/hooks/commit-msg         -a ! -f .git/hooks/applypatch-msg \
  -a ! -f .git/hooks/pre-applypatch     -a ! -f .git/hooks/post-applypatch \
  -a ! -f .git/hooks/pre-rebase         -a ! -f .git/hooks/pre-push \
  -a ! -f .git/hooks/pre-auto-gc        -a ! -f .git/hooks/pre-receive \
  -a ! -f .git/hooks/update             -a ! -f .git/hooks/post-receive \
  -a ! -f .git/hooks/fsmonitor-watchman -a ! -f .git/hooks/post-update \
] || DIE 1 "[FAIL]     $0   WANTED HOOKS SET"

echo "[ OK ]  $0     Version data for repo with commit"
unset ${!VERSION@}


echo "test 2${WIN_ECHO_EOL}" >>TEST.txt
git --no-pager add TEST.txt >/dev/null 2>&1
git commit -am "Second commit" >/dev/null 2>&1

source ver.sh

#for v in ${!VERSION@}; do declare -n z=$v; echo "$v = \"$z\""; done
#ls -la .git/hooks

# note: version stamps must be done by pre-commit hook, so non-null parent's SHA must be used
[ \
	   "0x00000002" == "${VERSION}" \
	-a "v0.0-2.MASTER" == "${VERSION_TEXT}" \
	-a "MASTER" == "${VERSION_BRANCH}" \
	-a "0000000000000000000000000000000000000000" != "${VERSION_SHA#p:}" \
	-a "000000000" != "${VERSION_SHA_ABBREV}" \
	-a "${VERSION_SHA:0:${#VERSION_SHA_ABBREV}}" == "${VERSION_SHA_ABBREV}" \
] || DIE 1 "[FAIL]  $0     Version information is wrong"

[ \
     -f .git/hooks/pre-commit           -a -f .git/hooks/post-checkout \
  -a -f .git/hooks/post-commit          -a -f .git/hooks/post-rewrite \
  -a -f .git/hooks/post-merge           -a ! -f .git/hooks/prepare-commit-msg \
  -a ! -f .git/hooks/commit-msg         -a ! -f .git/hooks/applypatch-msg \
  -a ! -f .git/hooks/pre-applypatch     -a ! -f .git/hooks/post-applypatch \
  -a ! -f .git/hooks/pre-rebase         -a ! -f .git/hooks/pre-push \
  -a ! -f .git/hooks/pre-auto-gc        -a ! -f .git/hooks/pre-receive \
  -a ! -f .git/hooks/update             -a ! -f .git/hooks/post-receive \
  -a ! -f .git/hooks/fsmonitor-watchman -a ! -f .git/hooks/post-update \
] || DIE 1 "[FAIL]     $0   WANTED HOOKS SET"

echo "[ OK ]  $0     Version data for repo with few commits"


popd >/dev/null 2>&1
