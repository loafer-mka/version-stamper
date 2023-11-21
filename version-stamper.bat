@echo off

rem +--------------------------------------------------------------------+
rem | This Source Code Form is subject to the terms of the Mozilla       |
rem | Public License, v. 2.0. If a copy of the MPL was not distributed   |
rem | with this file, You can obtain one at http://mozilla.org/MPL/2.0/. |
rem +--------------------------------------------------------------------+
rem        email: Andrey Makarov <mka-at-mailru@mail.ru>
rem Project home: https://github.com/loafer-mka/version-stamper.git
rem
rem               Copyright (c) Andrey Makarov 2023

if "%1" == "GIT-PATH" goto :GIT-PATH
if "%1" == "SHELL-PATH" goto :SHELL-PATH
if "%1" == "CYGPATH-PATH" goto :CYGPATH-PATH
goto :main

:GIT-PATH
WHERE "$PATH:git" 2>NUL
goto :EOF

:SHELL-PATH
echo %~dps2..
WHERE "%~dps2\usr\bin;%~dps2\..\usr\bin;%~dps2\bin;%~dps2\..\bin;%~dps2;%~dps2\..:sh" "%~dps2\usr\bin;%~dps2\..\usr\bin;%~dps2\bin;%~dps2\..\bin;%~dps2;%~dps2\..:bash" 2>NUL
goto :EOF

:CYGPATH-PATH
echo %~dps2..
WHERE "%~dps2\usr\bin;%~dps2\..\usr\bin;%~dps2\bin;%~dps2\..\bin;%~dps2;%~dps2\..:cygpath" "%~dps2\usr\bin;%~dps2\..\usr\bin;%~dps2\bin;%~dps2\..\bin;%~dps2;%~dps2\..:cygpath" 2>NUL
goto :EOF

:main
setlocal ENABLEDELAYEDEXPANSION
setlocal ENABLEEXTENSIONS

set GITUTIL=
for /F "tokens=*" %%P in ('"%~0" GIT-PATH') do (
	set GITUTIL=%%~sP
	set GITPATH=%%~dpsP
)
if "!GITUTIL!" == "" (
	echo FATAL: %0 cannot find git.exe utility, install please git for windows https://git-scm.com/download/win/
	goto :EOF
)

set SHELLUTIL=
for /F "tokens=*" %%P in ('"%~0" SHELL-PATH !GITPATH!') do set SHELLUTIL=%%~sP
if "!SHELLUTIL!" == "" (
	echo FATAL: %0 cannot find bash.exe and/or sh.exe utility, install please git for windows https://git-scm.com/download/win/
	goto :EOF
)

set PATHUTIL=
for /F "tokens=*" %%P in ('"%~0" CYGPATH-PATH !GITPATH!') do set PATHUTIL=%%~sP
if "!PATHUTIL!" == "" (
	echo FATAL: %0 cannot find bash.exe and/or sh.exe utility, install please git for windows https://git-scm.com/download/win/
	goto :EOF
)

set STAMPER='%~dpn0'
for /F "tokens=*" %%P in ('"!PATHUTIL!" -m !STAMPER!') do (
	!SHELLUTIL! -c '"%%P" %*'
	exit /b %errorlevel%
)

!SHELLUTIL! -c '"%~dpn0" %*'
exit /b %errorlevel%
