@echo off
cd /d "%~dp0"
chcp 65001 >nul 2>&1
mode con lines=24 cols=132
setlocal enabledelayedexpansion
title Windows SS-Tools 1.0
color 0F
call :Colors

:Compatability-Check
ver | find "10" >nul 2>&1
if not %errorlevel% == 0 (
    echo %BRIGHT_BLACK%Sorry, your system is not compatible with this tool%DARK_WHITE%
    pause
    exit
)

:Privileges-Check
openfiles 1>nul 2>&1
if not %errorlevel% == 0 (
    echo %BRIGHT_BLACK%To continue run this tool as %DARK_RED%administrator%DARK_WHITE%
    pause
    exit
)

:Main-Menu
cls
echo.
echo   %WHITE%██████%BRIGHT_RED%╗ %WHITE%██████%BRIGHT_RED%╗    %WHITE%████████%BRIGHT_BLUE%╗ %WHITE%█████%BRIGHT_BLUE%╗  %WHITE%█████%BRIGHT_BLUE%╗ %WHITE%██%BRIGHT_BLUE%╗      %WHITE%██████%BRIGHT_BLUE%╗
echo  %WHITE%██%BRIGHT_RED%╔════╝%WHITE%██%BRIGHT_RED%╔════╝    %BRIGHT_BLUE%╚══%WHITE%██%BRIGHT_BLUE%╔══╝%WHITE%██%BRIGHT_BLUE%╔══%WHITE%██%BRIGHT_BLUE%╗%WHITE%██%BRIGHT_BLUE%╔══%WHITE%██%BRIGHT_BLUE%╗%WHITE%██%BRIGHT_BLUE%║     %WHITE%██%BRIGHT_BLUE%╔════╝
echo  %BRIGHT_RED%╚%WHITE%█████%BRIGHT_RED%╗ ╚%WHITE%█████%BRIGHT_RED%╗ %WHITE%█████%BRIGHT_BLACK%╗ %WHITE%██%BRIGHT_BLUE%║   %WHITE%██%BRIGHT_BLUE%║  %WHITE%██%BRIGHT_BLUE%║%WHITE%██%BRIGHT_BLUE%║  %WHITE%██%BRIGHT_BLUE%║%WHITE%██%BRIGHT_BLUE%║     ╚%WHITE%█████%BRIGHT_BLUE%╗
echo   %BRIGHT_RED%╚═══%WHITE%██%BRIGHT_RED%╗ ╚═══%WHITE%██%BRIGHT_RED%╗%BRIGHT_BLACK%╚════╝ %WHITE%██%BRIGHT_BLUE%║   %WHITE%██%BRIGHT_BLUE%║  %WHITE%██%BRIGHT_BLUE%║%WHITE%██%BRIGHT_BLUE%║  %WHITE%██%BRIGHT_BLUE%║%WHITE%██%BRIGHT_BLUE%║      ╚═══%WHITE%██%BRIGHT_BLUE%╗%WHITE%
echo  %WHITE%██████%BRIGHT_RED%╔╝%WHITE%██████%BRIGHT_RED%╔╝       %WHITE%██%BRIGHT_BLUE%║   ╚%WHITE%█████%BRIGHT_BLUE%╔╝╚%WHITE%█████%BRIGHT_BLUE%╔╝%WHITE%███████%BRIGHT_BLUE%╗%WHITE%██████%BRIGHT_BLUE%╔╝%WHITE%
echo  %BRIGHT_RED%╚═════╝ ╚═════╝        %BRIGHT_BLUE%╚═╝    ╚════╝  ╚════╝ ╚══════╝╚═════╝%WHITE%
echo  %BRIGHT_BLACK%Welcome %UNDERLINE%%username%%NO_UNDERLINE% ^<3%WHITE%
echo ══════════════════════════════════════════════════════════════
echo.                                            %BRIGHT_BLACK%Twitter @Sphiment_%WHITE%
for /f "tokens=1,2,* delims=_ " %%A in ('"findstr /b /c:":Menu_" "%~f0""') do (
    echo  !BRIGHT_GREEN!%%B !WHITE!%%C
)
echo.
set "choice="
set /p choice=%DARK_WHITE%Choose an option to continue: %DARK_GREEN%
color 0F
call:Menu_[%choice%]
goto :Main-Menu


:Menu_[1] Registry Tweaks
cls 
reg import Registry.reg
taskkill /f /im explorer.exe>nul
start explorer 
pause
goto :eof

:Menu_

:Menu_[I] Info
cls
echo By ~Sphiment ^| Twitter: @Sphiment_
echo Inspired by Zaphyr5828, ArtanisInc
echo.
pause
goto :eof

:Menu_[E] Exit
exit


:BackUp-Warn
cls
choice /c:YN /m "Did you back up your system"
if not %errorlevel% == 1 (
    cls
    echo %BRIGHT_BLACK%Please back up your system to prevent any %DARK_RED%errors or damages %BRIGHT_BLACK%then try to run the tool%DARK_WHITE%
    pause
    exit /b
)

:Colors
set "DARK_RED=[31m"
set "DARK_GREEN=[32m"
set "DARK_BLUE=[34m"
set "DARK_CYAN=[36m"
set "DARK_WHITE=[37m"
set "BRIGHT_BLACK=[90m"
set "BRIGHT_RED=[91m"
set "BRIGHT_GREEN=[92m"
set "BRIGHT_BLUE=[94m"
set "BRIGHT_CYAN=[96m"
set "WHITE=[97m"
set "UNDERLINE=[4m"
set "NO_UNDERLINE=[24m"