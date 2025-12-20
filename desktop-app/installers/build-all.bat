@echo off
REM CliniScribe Unified Installer Build Script for Windows
REM Builds installers with a single command

setlocal enabledelayedexpansion

REM Configuration
set VERSION=1.0.0
set SCRIPT_DIR=%~dp0
set PROJECT_ROOT=%SCRIPT_DIR%..

echo.
echo ========================================================
echo.
echo          CliniScribe Installer Builder
echo.
echo ========================================================
echo.

REM Parse arguments
if "%1"=="" (
    echo No arguments provided.
    goto :show_usage
)

set BUILD_WINDOWS=0

:parse_args
if "%1"=="" goto :end_parse
if /i "%1"=="--all" (
    set BUILD_WINDOWS=1
    echo Note: Windows can only build Windows installers
    echo For macOS/Linux, build on those platforms
)
if /i "%1"=="--windows" set BUILD_WINDOWS=1
if /i "%1"=="--current" set BUILD_WINDOWS=1
if /i "%1"=="--help" goto :show_usage
shift
goto :parse_args
:end_parse

REM Build Windows installer
if %BUILD_WINDOWS%==1 (
    echo.
    echo ================================================
    echo   Building Windows Installer
    echo ================================================
    echo.

    REM Check if NSIS is installed
    where makensis >nul 2>nul
    if %errorlevel% neq 0 (
        echo ERROR: NSIS not found. Please install from:
        echo https://nsis.sourceforge.io/
        echo.
        pause
        exit /b 1
    )

    REM Build Tauri app first
    echo Building Tauri application...
    cd %PROJECT_ROOT%
    call npm run tauri:build
    if %errorlevel% neq 0 (
        echo ERROR: Tauri build failed
        pause
        exit /b 1
    )

    REM Build installer
    echo.
    echo Building NSIS installer...
    cd %SCRIPT_DIR%windows
    makensis cliniscribe.nsi
    if %errorlevel% neq 0 (
        echo ERROR: NSIS build failed
        pause
        exit /b 1
    )

    echo.
    echo [OK] Windows installer built successfully!
)

REM Show summary
echo.
echo ================================================
echo   Build Summary
echo ================================================
echo.
echo Built installers:
echo.
if exist "%PROJECT_ROOT%\installers\output\windows\*.exe" (
    echo Windows:
    dir /b "%PROJECT_ROOT%\installers\output\windows\*.exe"
) else (
    echo   (none)
)
echo.

echo Next steps:
echo   1. Test the installer on a clean Windows system
echo   2. Generate SHA256: certutil -hashfile installer.exe SHA256
echo   3. Create GitHub release and upload installer
echo   4. Update download links on website
echo.

echo.
echo ========================================================
echo.
echo              Build Complete!
echo.
echo ========================================================
echo.

goto :end

:show_usage
echo Usage: %0 [OPTIONS]
echo.
echo Options:
echo   --all              Build Windows installer
echo   --windows          Build Windows installer
echo   --current          Build for current platform (Windows)
echo   --help             Show this help message
echo.
echo Examples:
echo   %0 --windows       # Build Windows installer
echo   %0 --current       # Build for Windows
echo.
echo Note: For macOS and Linux installers, build on those platforms.
echo.
pause
exit /b 0

:end
pause
