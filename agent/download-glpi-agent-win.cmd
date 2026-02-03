@echo off
setlocal

REM ===== 設定 =====
set AGENT_VERSION=1.16
set MSI_NAME=GLPI-Agent-1.16-x64.msi
set DOWNLOAD_URL=https://github.com/glpi-project/glpi-agent/releases/download/1.16/GLPI-Agent-1.16-x64.msi

REM このバッチ自身のディレクトリ
set SCRIPT_DIR=%~dp0

REM ダウンロード先
set MSI_PATH=%SCRIPT_DIR%%MSI_NAME%

echo === GLPI Agent Downloader ===
echo Target file: %MSI_PATH%

REM すでに存在する場合は再ダウンロードしない
if exist "%MSI_PATH%" (
    echo MSI already exists. Skipping download.
    goto :EOF
)

echo Downloading GLPI Agent %AGENT_VERSION%...

powershell -NoProfile -ExecutionPolicy Bypass ^
  -Command "Invoke-WebRequest -Uri '%DOWNLOAD_URL%' -OutFile '%MSI_PATH%'"

if errorlevel 1 (
    echo Download failed.
    exit /b 1
)

echo Download completed successfully.
exit /b 0