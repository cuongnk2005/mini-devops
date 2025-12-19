#!/usr/bin/env bash
# scripts/monitor.sh - Kiểm tra sức khỏe website (Health Check)

# Dừng script ngay nếu có lỗi (set -e) hoặc biến chưa định nghĩa (set -u)
set -euo pipefail

# --- CẤU HÌNH ---
# Nhận biến từ Jenkins, nếu không có thì dùng giá trị mặc định
APP_DIR="${APP_DIR:-/srv/devops-demo}"
LOG_DIR="${LOG_DIR:-/srv/devops-demo/logs}"
WEB_PORT="${WEB_PORT:-80}"

# File log riêng cho monitor
MONITOR_LOG="$LOG_DIR/monitor.log"
TARGET_URL="http://localhost:$WEB_PORT"

echo "--- [MONITOR] Starting Health Check ---"

# 1. Đợi Web Server khởi động
# Vì container vừa bật lên cần vài giây để Nginx sẵn sàng nhận kết nối
echo "-> Waiting 5 seconds for service startup..."
sleep 5

# 2. Gửi request kiểm tra (Probe)
echo "-> Checking URL: $TARGET_URL"

# Lệnh curl:
# -f: Fail (báo lỗi) nếu HTTP code là lỗi (404, 500...)
# -s: Silent (không hiện thanh tải xuống)
# -S: Show error (hiện thông báo lỗi nếu không kết nối được)
if curl -fsS "$TARGET_URL" > /dev/null; then
    # --- TRƯỜNG HỢP THÀNH CÔNG ---
    MSG="[SUCCESS] Web is UP & Running (HTTP 200) at $(date)"
    
    # In chữ màu xanh lá cây ra màn hình Jenkins
    printf "\033[32m$MSG\033[0m\n"
    
    # Ghi vào file log
    echo "$MSG" >> "$MONITOR_LOG"
    
    # Báo cho Jenkins biết là OK
    exit 0
else
    # --- TRƯỜNG HỢP THẤT BẠI ---
    MSG="[FAILURE] Web is DOWN or Unreachable at $(date)"
    
    # In chữ màu đỏ ra màn hình Jenkins
    printf "\033[31m$MSG\033[0m\n"
    
    # Ghi vào file log
    echo "$MSG" >> "$MONITOR_LOG"
    
    # In ra 10 dòng log cuối của container để debug nhanh
    echo "--- Last 10 lines of container logs ---"
    docker logs --tail 10 devopsdemo-nginx || true
    
    # Báo cho Jenkins biết là LỖI (Dừng pipeline)
    exit 1
fi