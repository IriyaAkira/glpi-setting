@echo off
setlocal

set NEW_SERVER=https://test.test.com/front/inventory.php
set KEY1=HKLM\SOFTWARE\GLPI-Agent
set KEY2=HKLM\SOFTWARE\WOW6432Node\GLPI-Agent

reg query "%KEY1%" >nul 2>&1
if %errorlevel%==0 (
    set TARGET=%KEY1%
) else (
    set TARGET=%KEY2%
)

REM ===== GLPI-Agent ディレクトリ確認 =====
set AGENT_DIR=C:\Program Files\GLPI-Agent

REM AGENT_DIR が存在しない場合は一時ログに記録して終了する
if not exist "%AGENT_DIR%" (
    set LOG_PATH=%TEMP%\change-server.log
    echo [%DATE% %TIME%] AGENT_DIR not found: %AGENT_DIR%. Aborting. >> "%LOG_PATH%"
    goto end_script
)
set LOG_PATH=%AGENT_DIR%\change-server.log

REM ===== ログファイルが存在していたら削除 =====
if exist "%LOG_PATH%" (
    del "%LOG_PATH%"
)

echo ==== change-server.cmd run at %DATE% %TIME% ==== >> "%LOG_PATH%"
echo Target registry: %TARGET% >> "%LOG_PATH%"

REM ===== 現在のサーバー値を取得して確認 =====
for /f "skip=2 tokens=3*" %%A in ('reg query "%TARGET%" /v server 2^>nul') do set CURRENT_SERVER=%%A

echo [%DATE% %TIME%] Current server value: %CURRENT_SERVER% >> "%LOG_PATH%"
echo [%DATE% %TIME%] New server value: %NEW_SERVER% >> "%LOG_PATH%"

if "%CURRENT_SERVER%"=="%NEW_SERVER%" (
    echo [%DATE% %TIME%] Already set to %NEW_SERVER%. Skipping reg add and service restart >> "%LOG_PATH%"
    goto skip_update
)

echo [%DATE% %TIME%] Updating registry (server) >> "%LOG_PATH%"
reg add "%TARGET%" /v server /t REG_SZ /d "%NEW_SERVER%" /f >> "%LOG_PATH%" 2>&1
echo [%DATE% %TIME%] Stopping glpi-agent >> "%LOG_PATH%"
net stop "glpi-agent" >> "%LOG_PATH%" 2>&1
echo [%DATE% %TIME%] Starting glpi-agent >> "%LOG_PATH%"
net start "glpi-agent" >> "%LOG_PATH%" 2>&1

:skip_update

set SHORTCUT_PATH=%AGENT_DIR%\GLPI-Agent Web Console.url

if exist "%AGENT_DIR%" (

    echo インターネットショートカットを作成します...
    echo [%DATE% %TIME%] Creating shortcut at %SHORTCUT_PATH% >> "%LOG_PATH%"

    (
        echo [InternetShortcut]
        echo URL=http://localhost:62354/
    ) > "%SHORTCUT_PATH%"

    echo ショートカット作成完了
    echo [%DATE% %TIME%] Shortcut created >> "%LOG_PATH%"

) else (
    echo GLPI-Agent ディレクトリが存在しないためスキップします
    echo [%DATE% %TIME%] GLPI-Agent directory not found, skipped shortcut creation >> "%LOG_PATH%"
)

echo 更新完了
echo [%DATE% %TIME%] update complete >> "%LOG_PATH%"

:end_script
endlocal
