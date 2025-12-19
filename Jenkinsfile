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
    echo 'Copy deploy.sh mới nhất sang server...'

    sh '''
      set -euo pipefail

      # Copy deploy.sh từ workspace sang thư mục chạy thật
      cp -f scripts/deploy.sh /srv/devops-demo/deploy.sh
      chmod +x /srv/devops-demo/deploy.sh

      echo "\\033[36m[Deploy]\\033[0m Triển khai web từ Jenkins WORKSPACE"
      
      # Truyền WORKSPACE_DIR để deploy.sh copy từ workspace ra /srv/devops-demo/site
      WORKSPACE_DIR="$WORKSPACE" \
      SRC_SITE_DIR="site" \
      SITE_DIR="/srv/devops-demo/site" \
      CONTAINER_NAME="devopsdemo-nginx" \
      COMPOSE_FILE="/srv/devops-demo/docker/docker-compose.yml" \
      /srv/devops-demo/deploy.sh

      echo "\\033[32m[OK]\\033[0m Deploy stage done"
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