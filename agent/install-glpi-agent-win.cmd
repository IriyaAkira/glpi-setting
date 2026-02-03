@echo off
setlocal

REM この cmd ファイルのあるディレクトリ
set SCRIPT_DIR=%~dp0

REM 設定ファイル読み込み
if not exist "%SCRIPT_DIR%glpi-agent.conf" (
    echo ERROR: glpi-agent.conf not found.
    exit /b 1
)

call "%SCRIPT_DIR%glpi-agent.conf"

REM 必須変数チェック
if "%GLPI_SERVER_URL%"=="" (
    echo ERROR: GLPI_SERVER_URL is not defined.
    exit /b 1
)

REM MSI ファイル
set MSI_FILE=%SCRIPT_DIR%GLPI-Agent-1.16-x64.msi

if not exist "%MSI_FILE%" (
    echo ERROR: MSI file not found: %MSI_FILE%
    exit /b 1
)

echo Installing GLPI Agent...
echo Server URL: %GLPI_SERVER_URL%

msiexec /i "%MSI_FILE%" ^
  /quiet ^
  SERVER="%GLPI_SERVER_URL%" ^
  /norestart

if errorlevel 1 (
    echo Installation failed.
    exit /b 1
)

echo Installation completed successfully.
exit /b 0
