pipeline {
  agent any

  options {
    timestamps()
    ansiColor('xterm')
  }

  environment {
    APP_DIR = "/srv/devops-demo"
    LOG_DIR = "/srv/devops-demo/logs"
  }

  stages {
    stage('Setup') {
      steps {
        echo "\u001B[36m[Setup]\u001B[0m 1. Chạy script Setup..."
        
        // --- SỬA LỖI Ở ĐÂY ---
        // Phải tạo thư mục cha trước, nếu không lệnh cp sẽ lỗi
        sh 'mkdir -p /srv/devops-demo' 
        
        // Sau đó mới copy file setup vào
        sh 'cp scripts/setup.sh /srv/devops-demo/scripts/setup.sh'
        sh 'chmod +x /srv/devops-demo/setup.sh'
        
        // Chạy file
        sh '/srv/devops-demo/setup.sh'
      }
    }

    stage('Deploy') {
      steps {
        echo "Copy deploy.sh mới nhất sang server..."
        
        // Cách viết này của bạn RẤT TỐT (dùng sh block)
        sh '''#!/usr/bin/env bash
          set -euo pipefail

          # Đảm bảo thư mục tồn tại (phòng hờ)
          mkdir -p "$APP_DIR"

          # Copy đè (-f) script deploy mới nhất
          cp -f scripts/deploy.sh "$APP_DIR/scripts/deploy.sh"
          chmod +x "$APP_DIR/deploy.sh"

          # Truyền biến Workspace cho script deploy biết đường tìm code
          export WORKSPACE_DIR="$WORKSPACE"

          echo "Đang khởi chạy deploy script..."
          "$APP_DIR/deploy.sh"
        '''
      }
    }

    stage('Monitor') {
      steps {
        echo "\u001B[36m[Monitor]\u001B[0m Health-check web"
        sh '''#!/usr/bin/env bash
          set -euo pipefail
          
          echo "Đợi 5 giây cho Nginx khởi động..."
          sleep 5

          echo "Kiểm tra kết nối..."
          if curl -fsS http://localhost >/dev/null; then
             printf "\\033[32m[OK]\u001B[0m Web trả về HTTP 200\\n"
          else
             printf "\\033[31m[FAIL]\u001B[0m Web không phản hồi\\n"
             exit 1
          fi
        '''
      }
    }
  }

  post {
    success {
      echo "\u001B[32m[SUCCESS]\u001B[0m Pipeline hoàn tất"
    }
    failure {
      echo "\u001B[31m[FAILURE]\u001B[0m Pipeline thất bại"
      // Lệnh in log lỗi nếu cần
      sh 'tail -n 20 /srv/devops-demo/logs/deploy.log || true'
    }
  }
}