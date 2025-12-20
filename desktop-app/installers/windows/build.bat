@echo off
echo Building Windows Installer for CliniScribe...

REM Build Tauri app first
cd ..\..
call npm run tauri:build

REM Check if NSIS is installed
where makensis >nul 2>nul
if %errorlevel% neq 0 (
    echo ERROR: NSIS not found. Please install from https://nsis.sourceforge.io/
    exit /b 1
)

REM Create output directory
if not exist "installers\output\windows" mkdir installers\output\windows

REM Build installer with NSIS
cd installers\windows
makensis cliniscribe.nsi

echo.
echo ========================================
echo Build complete!
echo ========================================
echo.
echo Installer: installers\output\windows\CliniScribe-Setup-1.0.0.exe
echo.
echo To test: Run the installer as Administrator
echo.

pause
