#!/bin/bash
set -eu

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASE_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
DOCKER_BIN="/usr/bin/docker"
SCRIPT_NAME="$(basename "${BASH_SOURCE[0]}")"
LOG_DIR="$(cd "${SCRIPT_DIR}/logs" && pwd)"
LOG_FILE="${LOG_DIR}/${SCRIPT_NAME%.*}.log"

# ===== ログディレクトリ作成 =====
mkdir -p "${LOG_DIR}"

# ===== ログ関数 =====
log_info() {
  echo "$(date '+%Y-%m-%d %H:%M:%S') [INFO] $1" | tee -a "${LOG_FILE}"
}
log_error() {
  echo "$(date '+%Y-%m-%d %H:%M:%S') [ERROR] $1" | tee -a "${LOG_FILE}" >&2
}

# ===== エラーハンドラ =====
trap 'log_error "Script failed at line $LINENO"' ERR

# ===== root チェック =====
if [ "$(id -u)" -ne 0 ]; then
  log_error "${SCRIPT_NAME} must be run as root."
  exit 1
fi
log_info "${SCRIPT_NAME} running as root"

# ===== ログ開始 =====
log_info "===== Starting ${SCRIPT_NAME} (PID: $$) ====="

# ===== ログファイルの容量制限 =====
log_info "Starting log file size limit."
MAX_LINES=10000
if [[ -f "${LOG_FILE}" ]] && [[ $(wc -l < "${LOG_FILE}") -gt ${MAX_LINES} ]]; then
  tail -n "${MAX_LINES}" "${LOG_FILE}" > "${LOG_FILE}.tmp" && mv "${LOG_FILE}.tmp" "${LOG_FILE}"
  log_info "Log file rotated (kept last ${MAX_LINES} lines)."
fi

# ===== 事前準備 =====
# ディレクトリ作成
GLPI_DIR="${BASE_DIR}/storage/glpi"
GLPI_UID=33
GLPI_GID=33
if [ ! -d "$GLPI_DIR" ]; then
  log_info "Creating directory: $GLPI_DIR"
  mkdir -p "$GLPI_DIR"
else
  log_info "Directory already exists: $GLPI_DIR"
fi

# 所有権変更（常に実行して冪等性を確保）
log_info "Setting ownership to ${GLPI_UID}:${GLPI_GID}"
chown -R ${GLPI_UID}:${GLPI_GID} "$GLPI_DIR"

# ===== Docker Compose 起動 =====
log_info "Starting glpi server..."
if "${DOCKER_BIN}" compose up -d 2>&1 | tee -a "${LOG_FILE}"; then
    log_info "glpi server started successfully."
else
    log_error "Failed to start glpi server."
    exit 1
fi

# ===== 定期バックアップ用のcron設定 =====
log_info "Setting cron..."
## cron 設定
BACKUP_SCRIPT="${SCRIPT_DIR}/backup.sh"
CRON_TAG="glpi_backup"
CRON_LINE="0 3 * * * PATH=/usr/bin:/bin ${BACKUP_SCRIPT} # ${CRON_TAG}"

## 既存crontab取得
log_info "Retrieving existing crontab..."
CURRENT_CRON="$(crontab -l 2>/dev/null || true)"

## 既存登録があれば削除
log_info "Filtering existing cron entries..."
FILTERED_CRON="$(printf "%s\n" "${CURRENT_CRON}" | grep -v "${CRON_TAG}" || true)"

## 新規登録
if printf "%s\n%s\n" "${FILTERED_CRON}" "${CRON_LINE}" | crontab - 2>&1 | tee -a "${LOG_FILE}"; then
    log_info "Cron job registered successfully"
else
    log_error "Failed to register cron job."
    exit 1
fi

# ===== ログ終了 =====
log_info "===== Finished ${SCRIPT_NAME} (PID: $$) ====="
