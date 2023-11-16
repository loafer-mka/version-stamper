#!/bin/bash

pushd "$(dirname "$0")"

if [ -z "${DELIM_ROW}" ]; then
	source ./lib.sh
fi

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

echo "> git --no-pager init --bare \"./repos/bare0.git\""
GIT_INIT "./repos/bare0.git" --bare

echo "> git --no-pager init --bare \"./repos/bare1.git\""
GIT_INIT "./repos/bare1.git" --bare

echo "> git --no-pager init \"./repos/fresh\""
GIT_INIT "./repos/fresh"

echo "> git --no-pager init \"./repos/contrib\""
GIT_INIT "./repos/contrib"

echo "> pushd \"./repos/contrib\""
pushd "./repos/contrib"

echo "> git --no-pager remote add 'origin/one' ../bare0.git"
git --no-pager remote add 'origin/one' ../bare0.git
echo "> git --no-pager remote add 'origin' ../bare1.git"
git --no-pager remote add 'origin' ../bare1.git

echo "> git --no-pager fetch --all"
git --no-pager fetch --all

M="Initial"
echo "> rm README.txt"
rm README.txt 2>/dev/null
N=1
for A in A B C D E F G H I J K L M N O P Q R S T U V W X Y Z ; do
	echo -e ".gitattributes  text eol=lf\n.gitignore  text eol=lf\n.gitmodules  text eol=lf\n*.txt  text" >.gitattributes
	echo "${A}${WIN_ECHO_EOL}" >>README.txt
	echo "> git --no-pager add  .gitattributes  README.txt"
	git --no-pager add .gitattributes
	git --no-pager add README.txt
	echo "> git --no-pager commit -m \"${A} : ${M} commit\""
	git --no-pager commit -m "${A} : ${M} commit"
	sleep 1s
	case "${A}" in
	A)
		echo "> git --no-pager branch -- \"${A}0\""
		git --no-pager branch -- "${A}0"
		;;
	F | K | P | U)
		echo "> git --no-pager branch -- \"${A}0\""
		git --no-pager branch -- "${A}0"
		echo "> git --no-pager branch -- \"${A}\""
		git --no-pager branch -- "${A}"
		;;
	I | M)
		echo "> git --no-pager branch -- \"${A}/${A}0\""
		git --no-pager branch -- "${A}0"
		echo "> git --no-pager branch -- \"${A}/${A}\""
		git --no-pager branch -- "${A}/${A}"
		;;
	N)
		echo "> git --no-pager branch -- \"one/${A}0\""
		git --no-pager branch -- "one/${A}0"
		echo "> git --no-pager branch -- \"one/${A}\""
		git --no-pager branch -- "one/${A}"
		;;
	*)
		;;
	esac
	M="#${N}"
	((N++))
done

for B in F K P U "I/I" "M/M" "one/N"; do
	echo "> git --no-pager checkout \"${B}\""
	git --no-pager checkout "${B}"
	for N in 1 2 3 4 5 6; do
		echo "${B}${N}${WIN_ECHO_EOL}" >>README.txt
		echo "> git --no-pager commit -am \"${B}${N} commit\""
		git --no-pager commit -am "${B}${N} commit"
		sleep 1s
	done
done

echo "> git --no-pager checkout master"
git --no-pager checkout master

# echo "> git gc"
# git gc
# do not use garbage collector -- many local referencies goes into packed
# refs -> it is not too easy to look by eyes in files and folders

for B in A0 F K P U "I/I" "M/M" "master" ; do
	echo "> git push \"origin/one\" \"${B}:${B}\""
	git push "origin/one" "${B}:${B}"
done

for B in F "one/N" ; do
	echo "> git push \"origin\" \"${B}:${B}\""
	git push "origin" "${B}:${B}"
done

echo "> git --no-pager push \"origin/one\" \"U0:U0\""
git --no-pager push "origin/one" "U0:U0"
# the "origin/one"/"N" branch has same refname as "origin"/"one/N" ...
echo "> git --no-pager push \"origin/one\" \"one/N:N\""
git --no-pager push "origin/one" "one/N:N"
echo "> git fetch --all"
git fetch --all

echo "> git --no-pager checkout -B SUBMOD M/M^^^"
git --no-pager checkout -B SUBMOD M/M^^^
echo "> git submodule add -b U --name origin_one-U -- ../bare0.git ./sub1"
git submodule add -b U --name origin_one-U -- ../bare0.git ./sub1
echo "> git submodule add -b U0 --name origin_one-U0 -- ../bare0.git ./sub0"
git submodule add -b U0 --name origin_one-U0 -- ../bare0.git ./sub0
echo "> git submodule add -b one/N --name origin-one_N -- ../bare1.git ./sub2"
git submodule add -b one/N --name origin-one_N -- ../bare1.git ./sub2
echo "> git submodule add -b F --name origin-F -- ../bare1.git ./sub3"
git submodule add -b F --name origin-F -- ../bare1.git ./sub3

echo "> git add .gitmodules"
git add .gitmodules
echo "> git commit -am \"Add submodules\""
git commit -am "Add submodules"
echo "> git push \"origin/one\" \"SUBMOD:SUBMOD\""
git push "origin/one" "SUBMOD:SUBMOD"

echo "> git --no-pager log --graph --oneline --all"
git --no-pager log --graph --oneline --all
echo "> git --no-pager branch --all --verbose"
git --no-pager branch --all --verbose

echo "> popd"
popd

echo "> git --no-pager clone --branch master ./repos/bare0.git ./repos/clone-a"
git --no-pager clone --branch master ./repos/bare0.git ./repos/clone-a

echo "> git --no-pager clone --branch SUBMOD ./repos/bare0.git ./repos/clone-e"
git --no-pager clone --branch SUBMOD ./repos/bare0.git ./repos/clone-e

echo "> git --no-pager clone --branch SUBMOD --recurse-submodules ./repos/bare0.git ./repos/clone-m"
git --no-pager clone --branch SUBMOD --recurse-submodules ./repos/bare0.git ./repos/clone-m

# detached head above branch label (in future)
# extra non-version tags were added
echo "> git --no-pager clone --branch F ./repos/bare1.git ./repos/detach-f"
git --no-pager clone --branch F ./repos/bare1.git ./repos/detach-f
pushd ./repos/detach-f
echo "> git checkout \$(git --no-pager rev-parse F)"
git checkout $(git --no-pager rev-parse F)
for n in 1 2 3 4 5 ; do
	echo "Detach ${n}${WIN_ECHO_EOL}" >>README.txt
	echo "> git commit -am 'Detach ${n}'"
	git commit -am "Detach ${n}"
	sleep 1s
done
echo "> git tag tag-2 HEAD^^"
git tag tag-2 HEAD^^
echo "> git tag tag-1 F^^"
git tag tag-1 F^^
echo "> git tag x1.2 F^^^^^^^^"
git tag x1.2 F^^^^^^^^
popd

# detached head below branch label (in past)
# extra non-version tags were added
echo "> git --no-pager clone --branch F ./repos/bare1.git ./repos/detach-p"
git --no-pager clone --branch F ./repos/bare1.git ./repos/detach-p
pushd ./repos/detach-p
echo "> git checkout \$(git --no-pager rev-parse F)"
git checkout $(git --no-pager rev-parse F)
for n in 1 2 3 4 5 ; do
	echo "Detach ${n}${WIN_ECHO_EOL}" >>README.txt
	echo "> git commit -am 'Detach ${n}'"
	git commit -am "Detach ${n}"
	sleep 1s
done
echo "> git tag tag-3 HEAD"
git tag tag-3 HEAD
echo "> git tag tag-2 HEAD^^"
git tag tag-2 HEAD^^
echo "> git tag tag-1 F^^^^"
git tag tag-1 F^^^^
echo "> git checkout \$(git --no-pager rev-parse F^^)"
git checkout $(git --no-pager rev-parse F^^)
echo "> git tag x1.2 HEAD^^^^"
git tag x1.2 HEAD^^^^
popd

popd
