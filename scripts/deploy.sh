#!/usr/bin/env bash
# deploy.sh - Deploy từ Jenkins workspace sang Nginx (Docker)
# KHÔNG git pull/clone nữa

set -euo pipefail

### CẤU HÌNH ###

# Thư mục workspace của Jenkins (nơi Jenkins đã checkout code)
# Ví dụ job tên: mini-devops-demo  -> /var/lib/jenkins/workspace/mini-devops-demo
WORKSPACE_DIR="${WORKSPACE_DIR:-/var/lib/jenkins/workspace/mini-devops-demo}"

# Thư mục chứa web trong repo (bạn đang dùng site/)
SRC_SITE_DIR="${SRC_SITE_DIR:-site}"

# Thư mục web thật trên server (volume mount vào nginx)
SITE_DIR="${SITE_DIR:-/srv/devops-demo/site}"

# Log
LOG_FILE="${LOG_FILE:-/srv/devops-demo/logs/deploy.log}"

# Tên container nginx (phải trùng docker-compose.yml: container_name)
CONTAINER_NAME="${CONTAINER_NAME:-devopsdemo-nginx}"

# File docker-compose (nếu cần fallback up -d)
COMPOSE_FILE="${COMPOSE_FILE:-/srv/devops-demo/docker/docker-compose.yml}"

### KHÔNG CẦN SỬA PHÍA DƯỚI ###

TS="$(date +'%Y-%m-%d %H:%M:%S')"
echo "[$TS] BẮT ĐẦU DEPLOY (from Jenkins workspace)..." | tee -a "$LOG_FILE"

# Đảm bảo thư mục tồn tại
mkdir -p "$SITE_DIR" "$(dirname "$LOG_FILE")"

# 1) Kiểm tra workspace có tồn tại không
if [ ! -d "$WORKSPACE_DIR" ]; then
  echo "[$TS] LỖI: Không thấy WORKSPACE_DIR=$WORKSPACE_DIR" | tee -a "$LOG_FILE"
  exit 1
fi

# 2) Kiểm tra thư mục site/ trong workspace
SRC_PATH="$WORKSPACE_DIR/$SRC_SITE_DIR"
if [ ! -d "$SRC_PATH" ]; then
  echo "[$TS] LỖI: Không thấy thư mục '$SRC_SITE_DIR' trong workspace: $SRC_PATH" | tee -a "$LOG_FILE"
  echo "[$TS] Gợi ý: nếu web nằm ở thư mục khác (vd: public/), set SRC_SITE_DIR=public" | tee -a "$LOG_FILE"
  exit 1
fi

# 3) Lấy commit id từ workspace (nếu có .git)
COMMIT_ID="unknown"
if [ -d "$WORKSPACE_DIR/.git" ]; then
  COMMIT_ID="$(git -C "$WORKSPACE_DIR" rev-parse --short HEAD || echo 'unknown')"
fi
echo "[$TS] Deploy commit: $COMMIT_ID" | tee -a "$LOG_FILE"

# 4) Đồng bộ site/ từ workspace sang SITE_DIR
rsync -av --delete "$SRC_PATH/" "$SITE_DIR/" | tee -a "$LOG_FILE"

# 5) Chèn timestamp & commit vào index.html (nếu có placeholder)
if [ -f "$SITE_DIR/index.html" ]; then
  sed -i "s/__TS__/$TS/g" "$SITE_DIR/index.html" || true
  sed -i "s/__COMMIT__/$COMMIT_ID/g" "$SITE_DIR/index.html" || true
fi

# 6) Restart nginx container (hoặc compose up)
if docker ps --format '{{.Names}}' | grep -q "^$CONTAINER_NAME$"; then
  echo "[$TS] Restart container $CONTAINER_NAME..." | tee -a "$LOG_FILE"
  docker restart "$CONTAINER_NAME" >/dev/null 2>&1 || {
    echo "[$TS] CẢNH BÁO: restart thất bại, thử docker-compose up -d" | tee -a "$LOG_FILE"
    docker-compose -f "$COMPOSE_FILE" up -d
  }
else
  echo "[$TS] Container $CONTAINER_NAME chưa chạy, tiến hành docker-compose up -d..." | tee -a "$LOG_FILE"
  docker-compose -f "$COMPOSE_FILE" up -d
fi

echo "[$TS] DEPLOY THÀNH CÔNG (commit=$COMMIT_ID)" | tee -a "$LOG_FILE"
exit 0
