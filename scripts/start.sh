#!/usr/bin/env bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
GLPI_DIR="${SCRIPT_DIR}/../storage/glpi"
GLPI_UID=33
GLPI_GID=33

echo "=== GLPI Docker startup ==="

# ディレクトリ作成（存在していれば何もしない）
if [ ! -d "$GLPI_DIR" ]; then
  echo "Creating directory: $GLPI_DIR"
  mkdir -p "$GLPI_DIR"
else
  echo "Directory already exists: $GLPI_DIR"
fi

# 所有権変更（常に実行して冪等性を確保）
echo "Setting ownership to ${GLPI_UID}:${GLPI_GID}"
sudo chown -R ${GLPI_UID}:${GLPI_GID} "$GLPI_DIR"

# Docker Compose 起動
echo "Starting docker compose..."
docker compose up -d

echo "=== Done ==="
