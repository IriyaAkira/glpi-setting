#!/bin/bash
set -eu

# ===== 固定パス定義 =====
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASE_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
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

# ===== ログ開始 =====
log_info "===== Starting ${SCRIPT_NAME} (PID: $$) ====="

# ===== ログファイルの容量制限 =====
log_info "Starting log file size limit."
MAX_LINES=10000
if [[ -f "${LOG_FILE}" ]] && [[ $(wc -l < "${LOG_FILE}") -gt ${MAX_LINES} ]]; then
  tail -n "${MAX_LINES}" "${LOG_FILE}" > "${LOG_FILE}.tmp" && mv "${LOG_FILE}.tmp" "${LOG_FILE}"
  log_info "Log file rotated (kept last ${MAX_LINES} lines)."
fi

# ===== CSR & 秘密鍵生成 =====
CERT_DIR="$(cd "${BASE_DIR}/nginx/certs" && pwd)"
KEY_FILE="${CERT_DIR}/glpi.key"
CSR_FILE="${CERT_DIR}/glpi.csr"
CONFIG_FILE="${CERT_DIR}/openssl-nps.cnf"

log_info "Start generating CSR..."

if ! command -v openssl &> /dev/null; then
    log_error "OpenSSL is not installed."
    exit 1
fi

# 設定ファイル存在確認
if [ ! -f "$CONFIG_FILE" ]; then
    log_error "Config file $CONFIG_FILE not found."
    exit 1
fi

# CSRと鍵を生成
openssl req -new \
  -newkey rsa:2048 \
  -nodes \
  -keyout "$KEY_FILE" \
  -out "$CSR_FILE" \
  -config "$CONFIG_FILE"

if [ $? -eq 0 ]; then
    log_info "Successfully generated:"
    log_info "  Private Key: $KEY_FILE"
    log_info "  CSR:         $CSR_FILE"
else
    log_info "OpenSSL command failed."
    exit 1
fi

# ===== ログ終了 =====
log_info "===== Finished ${SCRIPT_NAME} (PID: $$) ====="