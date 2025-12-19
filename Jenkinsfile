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
    echo "Copy deploy.sh mới nhất sang server..."

    sh '''#!/usr/bin/env bash
      set -euo pipefail

      APP_DIR="/srv/devops-demo"
      mkdir -p "$APP_DIR"

      cp -f scripts/deploy.sh "$APP_DIR/deploy.sh"
      chmod +x "$APP_DIR/deploy.sh"

      # Truyền workspace cho deploy.sh
      export WORKSPACE_DIR="$WORKSPACE"

      "$APP_DIR/deploy.sh"
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