#!/usr/bin/env bash
# deploy.sh - Kéo code từ GitHub & triển khai lên Nginx (Docker)
# Chạy được cả bằng tay lẫn trong Jenkins

set -euo pipefail

### CẤU HÌNH (SỬA CHO ĐÚNG MÔI TRƯỜNG CỦA BẠN) ###

# URL repo GitHub của nhóm
#REPO_URL="${REPO_URL:-https://github.com/<user-hoặc-org>/<tên-repo>.git}"
REPO_URL="https://github.com/cuongnk2005/mini-devops.git"
# Nhánh chính
BRANCH="${BRANCH:-main}"

# Thư mục trên server
REPO_DIR="/srv/devops-demo/repo"
SITE_DIR="/srv/devops-demo/site"
LOG_FILE="/srv/devops-demo/logs/deploy.log"

# Tên container nginx (trùng với docker-compose.yml: container_name)
CONTAINER_NAME="${CONTAINER_NAME:-devopsdemo-nginx}"

### KHÔNG CẦN SỬA PHÍA DƯỚI (trừ khi bạn muốn tuỳ biến) ###

TS="$(date +'%Y-%m-%d %H:%M:%S')"

echo "[$TS] BẮT ĐẦU DEPLOY..." | tee -a "$LOG_FILE"

# Đảm bảo thư mục tồn tại
mkdir -p "$REPO_DIR" "$SITE_DIR" "$(dirname "$LOG_FILE")"

# 1) Clone hoặc update repo
if [ ! -d "$REPO_DIR/.git" ]; then
    echo "[$TS] Chưa có repo, tiến hành clone..." | tee -a "$LOG_FILE"
    git clone --branch "$BRANCH" --depth 1 "$REPO_URL" "$REPO_DIR"
else
    echo "[$TS] Repo đã tồn tại, tiến hành fetch & reset..." | tee -a "$LOG_FILE"
    git -C "$REPO_DIR" fetch --depth 1 origin "$BRANCH"
    git -C "$REPO_DIR" reset --hard "origin/$BRANCH"
fi

# Lấy mã commit hiện tại (ngắn gọn)
COMMIT_ID="$(git -C "$REPO_DIR" rev-parse --short HEAD || echo 'unknown')"
echo "[$TS] Đang deploy commit: $COMMIT_ID" | tee -a "$LOG_FILE"

# 2) Đồng bộ folder web/ từ repo sang SITE_DIR
# Nếu code web nằm ở chỗ khác (vd: src/, public/), sửa lại đường dẫn nguồn
# 2) Đồng bộ folder site/ từ repo sang SITE_DIR
if [ ! -d "$REPO_DIR/site" ]; then
    echo "[$TS] LỖI: Không tìm thấy thư mục '$REPO_DIR/site' trong repo!" | tee -a "$LOG_FILE"
    exit 1
fi

rsync -av --delete "$REPO_DIR/site/" "$SITE_DIR/" | tee -a "$LOG_FILE"

# 3) Chèn timestamp & commit vào index.html (nếu có placeholder)
if [ -f "$SITE_DIR/index.html" ]; then
    sed -i "s/__TS__/$TS/g" "$SITE_DIR/index.html" || true
    sed -i "s/__COMMIT__/$COMMIT_ID/g" "$SITE_DIR/index.html" || true
fi

# 4) Restart container Nginx
if docker ps --format '{{.Names}}' | grep -q "^$CONTAINER_NAME$"; then
    echo "[$TS] Restart container $CONTAINER_NAME..." | tee -a "$LOG_FILE"
    docker restart "$CONTAINER_NAME" >/dev/null 2>&1 || {
        echo "[$TS] CẢNH BÁO: restart thất bại, thử docker-compose up -d" | tee -a "$LOG_FILE"
        docker compose -f /srv/devops-demo/docker/docker-compose.yml up -d
    }
else
    echo "[$TS] Container $CONTAINER_NAME chưa chạy, tiến hành docker-compose up -d..." | tee -a "$LOG_FILE"
    docker compose -f /srv/devops-demo/docker/docker-compose.yml up -d
fi

echo "[$TS] DEPLOY THÀNH CÔNG (commit=$COMMIT_ID)" | tee -a "$LOG_FILE"
exit 0
