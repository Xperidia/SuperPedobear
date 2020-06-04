@echo off
set BACK_CD=%cd%
echo.
echo This script is here to make symbolic links to your game/server in order to have a clean installation.
echo.
echo.
echo This script require Windows Vista or greater.
echo.
echo This script require NTFS. As NTFS is the only widespread Windows file system with support for symbolic links.
echo.
echo This script will not work without Developer Mode enabled (in Windows 10 version 1703 and up) or without UAC elevation.
echo.
echo.
echo You typically only need to use this script once (per game/server directory).
echo.
echo.
echo.
set SOURCE_PATH=%~dp0
echo Source path is assumed to be: %SOURCE_PATH%
echo.
echo.
echo You need to input your full absolute garrysmod directory path without quotation marks.
echo.
echo.
echo It usually look like this:	X:\SteamLibrary\steamapps\common\GarrysMod\garrysmod
echo.
echo 		or this:	X:\steamcmd\steamapps\common\GarrysModDS\garrysmod
echo.
echo.
set /p TARGET_PATH=garrysmod directory absolute path:
echo.
@echo on
%TARGET_PATH:~0,2%
cd "%TARGET_PATH%"
mkdir gamemodes
mklink /D gamemodes\superpedobear "%SOURCE_PATH%gamemodes\superpedobear"
mkdir maps
mklink maps\spb_school.bsp "%SOURCE_PATH%maps\spb_school.bsp"
mklink maps\spb_school.nav "%SOURCE_PATH%maps\spb_school.nav"
mkdir maps\thumb
mklink maps\thumb\spb_school.png "%SOURCE_PATH%maps\thumb\spb_school.png"
@echo off
echo.
echo It should be done now. Please verify that no critical error occurred.
echo.
pause
%BACK_CD:~0,2%
cd "%BACK_CD%"
