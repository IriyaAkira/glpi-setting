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

echo 更新完了
endlocal
