#!/usr/bin/env bash
# scripts/setup.sh - Chuẩn bị môi trường trước khi deploy

set -eu

# Nhận biến từ Jenkins hoặc dùng mặc định
APP_DIR="${APP_DIR:-/srv/devops-demo}"
LOG_DIR="${LOG_DIR:-/srv/devops-demo/logs}"
REPO_DIR="${APP_DIR}/repo"

echo "--- [SETUP] BẮT ĐẦU ---"

# 1. Tạo cấu trúc thư mục
echo "-> Kiểm tra và tạo thư mục..."
if [ ! -d "$APP_DIR" ]; then
    echo "   Tạo mới: $APP_DIR"
    mkdir -p "$APP_DIR"
fi

if [ ! -d "$LOG_DIR" ]; then
    echo "   Tạo mới: $LOG_DIR"
    mkdir -p "$LOG_DIR"
fi

# Tạo sẵn thư mục repo để tránh lỗi cho deploy.sh
if [ ! -d "$REPO_DIR" ]; then
    mkdir -p "$REPO_DIR"
fi

# 2. Ghi log môi trường
SETUP_LOG="$LOG_DIR/setup.log"
echo "-> Ghi thông tin server vào $SETUP_LOG"

{
  echo "=============================="
  echo "SETUP RUN AT: $(date)"
  echo "USER: $(whoami)"
  echo "WORKDIR: $(pwd)"
} > "$SETUP_LOG"

# 3. Kiểm tra Docker (Bắt buộc)
if command -v docker &> /dev/null; then
    VER=$(docker --version)
    echo "-> DOCKER: $VER" | tee -a "$SETUP_LOG"
else
    echo "-> LỖI: Không tìm thấy Docker trên server!" | tee -a "$SETUP_LOG"
    exit 1
fi

# 4. Kiểm tra Docker Compose (Hỗ trợ cả bản cũ và mới)
if command -v docker-compose &> /dev/null; then
    VER=$(docker-compose version)
    echo "-> COMPOSE (Standalone): $VER" | tee -a "$SETUP_LOG"
elif docker compose version &> /dev/null; then
    VER=$(docker compose version)
    echo "-> COMPOSE (Plugin): $VER" | tee -a "$SETUP_LOG"
else
    echo "-> CẢNH BÁO: Không tìm thấy Docker Compose!" | tee -a "$SETUP_LOG"
fi

echo "--- [SETUP] HOÀN TẤT ---"