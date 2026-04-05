@echo off
chcp 65001 > nul
setlocal
cd /d "%~dp0"

set BUILD_DIR=%~dp0build
set OUTPUT=%BUILD_DIR%\Release\SaveAliasOld.aux2
set DEST=e:\important\aviutl2_latest\data\Plugin\SaveAliasOld.aux2

echo ==========================================
echo  Building...
echo ==========================================
powershell -ExecutionPolicy Bypass -File "%~dp0scripts\build.ps1" -Configuration Release
if errorlevel 1 (
    echo.
    echo [ERROR] Build failed
    pause
    exit /b 1
)

echo.
echo ==========================================
echo  Copying...
echo   %OUTPUT%
echo   -^> %DEST%
echo ==========================================
copy /y "%OUTPUT%" "%DEST%"
if errorlevel 1 (
    echo [ERROR] Copy failed
    pause
    exit /b 1
)

echo.
echo Done.
pause
