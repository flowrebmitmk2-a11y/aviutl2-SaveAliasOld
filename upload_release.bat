@echo off
setlocal

:: --- 設定 ---
set PLUGIN_NAME=SaveAliasOld
set BUILD_DIR=build
set RELEASE_ZIP_NAME=%PLUGIN_NAME%-Release.zip
set DEBUG_ZIP_NAME=%PLUGIN_NAME%-Debug.zip

:: 1. 引数（リリースタグ）のチェック
if "%~1"=="" (
    echo ERROR: このバッチにはリリースするタグ名が必要です。
    echo 例: %~n0 v1.0.0
    exit /b 1
)
set "RELEASE_TAG=%~1"

:: 2. gh CLI のチェック
where gh >nul 2>nul
if %errorlevel% neq 0 (
    echo ERROR: GitHub CLI 'gh'が見つかりません。
    echo https://cli.github.com/ からインストールしてください。
    exit /b 1
)

echo --- GitHub CLI 'gh' はインストール済みです。

:: 3. ビルドディレクトリの準備
if not exist "%BUILD_DIR%" mkdir "%BUILD_DIR%"
pushd "%BUILD_DIR%"

:: 4. CMakeプロジェクトの生成
echo --- CMakeプロジェクトを構成しています... ---
cmake .. -A Win32
if %errorlevel% neq 0 (
    echo ERROR: CMakeの構成に失敗しました。
    popd
    exit /b 1
)

:: 5. Releaseビルド
echo --- Release版をビルドしています... ---
cmake --build . --config Release
if %errorlevel% neq 0 (
    echo ERROR: Releaseビルドに失敗しました。
    popd
    exit /b 1
)

:: 6. Debugビルド
echo --- Debug版をビルドしています... ---
cmake --build . --config Debug
if %errorlevel% neq 0 (
    echo ERROR: Debugビルドに失敗しました。
    popd
    exit /b 1
)

echo --- ビルド成果物をZIPファイルに圧縮しています... ---

:: 7. Release成果物をZIP化
set "RELEASE_ARTIFACT_PATH=Release\%PLUGIN_NAME%.aux2"
if not exist "%RELEASE_ARTIFACT_PATH%" (
    echo ERROR: Releaseの成果物が見つかりません: %RELEASE_ARTIFACT_PATH%
    popd
    exit /b 1
)
powershell -Command "Compress-Archive -Path '%RELEASE_ARTIFACT_PATH%' -DestinationPath '%RELEASE_ZIP_NAME%' -Force"
echo %RELEASE_ZIP_NAME% を作成しました。

:: 8. Debug成果物をZIP化
set "DEBUG_ARTIFACT_PATH_1=Debug\%PLUGIN_NAME%.aux2"
set "DEBUG_ARTIFACT_PATH_2=Debug\%PLUGIN_NAME%.pdb"
if not exist "%DEBUG_ARTIFACT_PATH_1%" (
    echo ERROR: Debugの成果物が見つかりません: %DEBUG_ARTIFACT_PATH_1%
    popd
    exit /b 1
)
if not exist "%DEBUG_ARTIFACT_PATH_2%" (
    echo WARN: デバッグシンボルファイルが見つかりません: %DEBUG_ARTIFACT_PATH_2%
    powershell -Command "Compress-Archive -Path '%DEBUG_ARTIFACT_PATH_1%' -DestinationPath '%DEBUG_ZIP_NAME%' -Force"
) else (
    powershell -Command "Compress-Archive -Path '%DEBUG_ARTIFACT_PATH_1%', '%DEBUG_ARTIFACT_PATH_2%' -DestinationPath '%DEBUG_ZIP_NAME%' -Force"
)
echo %DEBUG_ZIP_NAME% を作成しました。

:: 9. GitHubリリースにアップロード
echo --- GitHubリリース '%RELEASE_TAG%' にアップロードしています... ---
gh release upload "%RELEASE_TAG%" "%RELEASE_ZIP_NAME%" "%DEBUG_ZIP_NAME%" --clobber
if %errorlevel% neq 0 (
    echo ERROR: GitHubへのアップロードに失敗しました。
    echo リリース '%RELEASE_TAG%' が存在すること、権限があることを確認してください。
    del /q "%RELEASE_ZIP_NAME%" "%DEBUG_ZIP_NAME%" >nul 2>nul
    popd
    exit /b 1
)

:: 10. クリーンアップ
echo --- 一時ファイルをクリーンアップしています... ---
del /q "%RELEASE_ZIP_NAME%" "%DEBUG_ZIP_NAME%" >nul 2>nul

popd

echo.
echo --- 正常にビルドし、リリース '%RELEASE_TAG%' に成果物をアップロードしました。 ---
endlocal
