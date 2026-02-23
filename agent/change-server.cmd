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

reg add "%TARGET%" /v server /t REG_SZ /d "%NEW_SERVER%" /f

net stop "glpi-agent" >nul 2>&1
net start "glpi-agent" >nul 2>&1

REM ===== GLPI-Agent ディレクトリ確認 =====

set AGENT_DIR=C:\Program Files\GLPI-Agent
set SHORTCUT_PATH=%AGENT_DIR%\GLPI-Agent Web Console.url

if exist "%AGENT_DIR%" (

    echo インターネットショートカットを作成します...

    (
        echo [InternetShortcut]
        echo URL=http://localhost:62354/
        echo IconFile=%SystemRoot%\system32\shell32.dll
        echo IconIndex=1
    ) > "%SHORTCUT_PATH%"

    echo ショートカット作成完了

) else (
    echo GLPI-Agent ディレクトリが存在しないためスキップします
)

echo 更新完了
endlocal
