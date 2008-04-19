echo off
rem XSupplicant Build Script
rem Author: Terry Simons (galimorerpg@users.sourceforge.net)

rem ---- Environment ----

echo on
set OPEN1X_BUILD_ROOT=%OPEN1X_BUILD_ROOT%
set OPEN1X_VENDOR_ROOT=%OPEN1X_VENDOR_ROOT%
set OPEN1X_LIBRARY_ROOT=%OPEN1X_LIBRARY_ROOT%
set QTDIR=%QTDIR%
set QMAKESPEC=%QMAKESPEC%
set OPEN1X_BUILD_SDK=%OPEN1X_BUILD_SDK%

if ["%OPEN1X_BUILD_ROOT%"]==[""] (
	set OPEN1X_BUILD_ROOT=..\..\..
)

if ["%OPEN1X_VENDOR_ROOT%"]==[""] (
	set OPEN1X_VENDOR_ROOT=C:\OpenSEA\vendor
)

if ["%OPEN1X_LIBRARY_ROOT%"]==[""] (
	set OPEN1X_LIBRARY_ROOT=C:\OpenSEA\thirdparty
)

if ["%OPEN1X_BUILD_SDK%"]==[""] (
	set OPEN1X_BUILD_SDK=C:\Program Files\Microsoft SDKs\Windows\v6.0\Bin
)

if ["%QTDIR%"]==[""] (
	set QTDIR=C:\Qt\qt-win-opensource-src-4.3.4
)

if [%QMAKESPEC%]==[] (
	set QMAKESPEC=win32-msvc2005
)

rem ---- Support Libraries ----

set LIBXML2DIR=%LIBXML2DIR%
set ICONVDIR=%ICONVDIR%
set OPENSSLDIR=%OPENSSLDIR%
set ZLIBDIR=%ZLIBDIR%
set LIBTNCDIR=%LIBTNCDIR%
set NUIOUSERDIR=%NUIOUSERDIR%

if [%LIBXML2DIR%]==[] (
	set LIBXML2DIR=%OPEN1X_LIBRARY_ROOT%\libxml2-2.6.30+.win32
)
if [%ICONVDIR%]==[] (
	set ICONVDIR=%OPEN1X_LIBRARY_ROOT%\iconv-1.9.2.win32
)
if [%OPENSSLDIR%]==[] (
	set OPENSSLDIR=%OPEN1X_LIBRARY_ROOT%\openssl-0.9.8g.win32
)
if [%ZLIBDIR%]==[] (
	set ZLIBDIR=%OPEN1X_LIBRARY_ROOT%\zlib-1.2.3.win32
)
if [%LIBTNCDIR%]==[] (
	set LIBTNCDIR=%OPEN1X_LIBRARY_ROOT%\libtnc-1.18
)

if [%NUIOUSERDIR%]==[] (
	set NUIOUSERDIR=C:\WinDDK\6000\src\network\ndis\ndisprot\5x\sys
)

rem ---- Open1X ----
set OPEN1X_ENGINE=%OPEN1X_BUILD_ROOT%\xsupplicant\vs2005
set OPEN1X_ENGINE_PLUGINS=%OPEN1X_BUILD_ROOT%\xsupplicant\plugins\vs2005
set OPEN1X_GUI=%OPEN1X_BUILD_ROOT%\xsupplicant-ui
set OPEN1X_GUI_PLUGINS=%OPEN1X_GUI%\plugins
set OPEN1X_PROTINSTALL=%OPEN1X_VENDOR_ROOT%\ProtInstall

rem ---- OEM ----

rem set OEM_GUI_PLUGINS=%OPEN1X_BUILD_ROOT%\OEM\UI Plugins
rem set OEM_ENGINE_PLUGINS=%OPEN1X_BUILD_ROOT%\OEM\Engine Plugins 

set BUILD_TYPE=%1
set BUILD_FLAGS=%2

rem Set the /RETAIL or /DEBUG flags depending on which release type we're using:
rem BUILD_TYPE=[Debug|Release]
if [%BUILD_TYPE%]==[Release] goto:Release
if [%BUILD_TYPE%]==[Debug] goto:Debug

rem Otherwise, squawk, then set the build type to release
echo Unknown Build Type: "%BUILD_TYPE%" - Setting to "Release"
set BUILD_TYPE=Release
goto Release

:Release
set BUILD_FLAGS=/Release %BUILD_FLAGS%
goto Done

:Debug
set BUILD_FLAGS=/Debug %BUILD_FLAGS%
goto Done

:Done

REM Source the Microsoft development environment...
REM Call "%OPEN1X_BUILD_SDK%\SetEnv.Cmd" %BUILD_FLAGS%

echo on

rem Dump the environment variables for debugging purposes
set

echo off

set BUILD_PROJECT="Open1X Engine"
copy %NUIOUSERDIR%\nuiouser.h %OPEN1X_ENGINE%\ndis_proto_driver
vcbuild /time "%OPEN1X_ENGINE%\Xsupplicant.sln" "%BUILD_TYPE% as Service with TNC|Win32" %BUILD_FLAGS%

set BUILD_ERROR=%ERRORLEVEL%

if NOT [%BUILD_ERROR%]==[0] goto FAIL

set BUILD_STATUS=PASS

echo %BUILD_PROJECT% Status: %BUILD_STATUS%

rem ----------------------------------------------

set BUILD_PROJECT="Open1X GUI"
vcbuild /time "%OPEN1X_GUI%\xsupplicant_gui.sln" "%BUILD_TYPE%|Win32" %BUILD_FLAGS%

set BUILD_ERROR=%ERRORLEVEL%

if NOT [%BUILD_ERROR%]==[0] goto FAIL

set BUILD_STATUS=PASS

echo %BUILD_PROJECT% Status: %BUILD_STATUS%

rem ----------------------------------------------

set BUILD_PROJECT="Open1X Engine Plugins"
vcbuild /time "%OPEN1X_ENGINE_PLUGINS%\Plugins.sln" "%BUILD_TYPE%|Win32" %BUILD_FLAGS%

set BUILD_ERROR=%ERRORLEVEL%

if NOT [%BUILD_ERROR%]==[0] goto FAIL

set BUILD_STATUS=PASS

echo %BUILD_PROJECT% Status: %BUILD_STATUS%

rem ----------------------------------------------

rem set BUILD_PROJECT="Open1X GUI Plugins"
rem vcbuild /time "%OPEN1X_GUI_PLUGINS%\Plugins.sln" "%BUILD_TYPE%|Win32" %BUILD_FLAGS%

rem set BUILD_ERROR=%ERRORLEVEL%

rem if NOT [%BUILD_ERROR%]==[0] goto FAIL

rem set BUILD_STATUS=PASS

rem echo %BUILD_PROJECT% Status: %BUILD_STATUS%

rem ----------------------------------------------

rem set BUILD_PROJECT="Open1X Protocol Installer"
vcbuild /time "%OPEN1X_PROTINSTALL%\ProtInstall.sln" "%BUILD_TYPE%|Win32" %BUILD_FLAGS%

set BUILD_ERROR=%ERRORLEVEL%

if NOT [%BUILD_ERROR%]==[0] goto FAIL

set BUILD_STATUS=PASS

echo %BUILD_PROJECT% Status: %BUILD_STATUS%

rem ----------------------------------------------

echo All projects built successfullly.

goto DONE

:FAIL
set BUILD_STATUS=FAIL
echo %BUILD_PROJECT% Status: %BUILD_STATUS%

:DONE