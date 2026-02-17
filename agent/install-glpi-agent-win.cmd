@echo off
setlocal EnableDelayedExpansion

REM 実行ファイルのあるフォルダへ移動
cd /d "%~dp0"

REM 設定ファイル確認
if not exist "glpi-agent.conf" (
    echo ERROR: glpi-agent.conf が見つかりません。
    exit /b 1
)

REM 変数初期化
set SERVER=

REM confファイルを読み込み
for /f "usebackq tokens=1,* delims==" %%A in ("glpi-agent.conf") do (
    if /I "%%A"=="GLPI_SERVER_URL" (
        set SERVER=%%B
    )
)

REM 値確認
if "%SERVER%"=="" (
    echo ERROR: GLPI_SERVER_URL が取得できません。
    exit /b 1
)

echo GLPI Server: %SERVER%

REM MSI存在確認
if not exist "GLPI-Agent-1.16-x64.msi" (
    echo ERROR: MSIファイルが見つかりません。
    exit /b 1
)

REM インストール実行
msiexec /i "GLPI-Agent-1.16-x64.msi" /quiet SERVER=%SERVER% /log install.log

endlocal
