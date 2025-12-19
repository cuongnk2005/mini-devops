pipeline {
  agent any

  options {
    timestamps()
    ansiColor('xterm')
    // QUAN TRỌNG: Đã xóa dòng skipDefaultCheckout(true) để Jenkins tự tải code về
  }

  environment {
    APP_DIR = "/srv/devops-demo"
    LOG_DIR = "/srv/devops-demo/logs"
  }

  stages {
    // Không cần stage Checkout thủ công nữa vì Jenkins sẽ tự làm ở bước đầu

    stage('Setup') {
      steps {
        echo "\u001B[36m[Setup]\u001B[0m Kiểm tra môi trường"
        sh '''#!/usr/bin/env bash
          set -eu
          mkdir -p "$LOG_DIR"
          
          # Tạo thư mục chứa script trên server nếu chưa có
          mkdir -p "$APP_DIR"
          
          {
            echo "== SETUP =="
            echo "DATE: $(date)"
            echo "WORKSPACE: $(pwd)"
            docker-compose version
          } >> "$LOG_DIR/setup.log"

          printf "\\033[32m[OK]\\033[0m Setup OK\\n"
        '''
      }
    }

    stage('Deploy') {
      steps {
        echo 'Copy file script mới nhất sang thư mục chạy...'
        
        // SỬA LỖI 2: Copy file và đặt tên rõ ràng để tránh nhầm lẫn
        // Copy từ workspace (scripts/deploy.sh) sang server (/srv/devops-demo/deploy.sh)
        sh 'cp scripts/deploy.sh /srv/devops-demo/deploy.sh'
        sh 'chmod +x /srv/devops-demo/deploy.sh'

        echo "\u001B[36m[Deploy]\u001B[0m Triển khai web"
        sh '''#!/usr/bin/env bash
          set -euo pipefail
          
          # Di chuyển vào thư mục ứng dụng
          cd "$APP_DIR"

          # SỬA LỖI 2: File giờ nằm ngay tại thư mục gốc, không phải trong folder scripts/ nữa
          if [[ ! -x deploy.sh ]]; then
            printf "\\033[31m[ERROR]\\033[0m Không tìm thấy file deploy.sh!\\n" >&2
            exit 1
          fi

          printf "\\033[33m[INFO]\\033[0m Chạy deploy.sh...\\n"
          
          # Chạy file script (Lưu ý: ./deploy.sh chứ không phải ./scripts/deploy.sh)
          ./deploy.sh
          
          printf "\\033[32m[OK]\\033[0m Deploy stage done\\n"
        '''
      }
    }

    stage('Monitor') {
      steps {
        echo "\u001B[36m[Monitor]\u001B[0m Health-check web"
        // (Giữ nguyên code cũ của bạn đoạn này)
        sh '''#!/usr/bin/env bash
          set -euo pipefail
          if curl -fsS http://localhost >/dev/null; then
             echo "OK"
          else
             echo "FAIL"
             exit 1
          fi
        '''
      }
    }
  }

  post {
    // (Giữ nguyên phần post của bạn)
    success {
      echo "\u001B[32m[SUCCESS]\u001B[0m Pipeline hoàn tất"
    }
    failure {
      echo "\u001B[31m[FAILURE]\u001B[0m Pipeline thất bại"
      // (Giữ nguyên lệnh log lỗi của bạn)
    }
  }
}