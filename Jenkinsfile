pipeline {
  agent any

  options {
    timestamps()
    ansiColor('xterm')   // cần ANSI Color plugin
  skipDefaultCheckout(true)
  }

  environment {
    APP_DIR = "/srv/devops-demo"
    LOG_DIR = "/srv/devops-demo/logs"
  }

  stages {

   // stage('Checkout') {
     // steps {
       // echo "\u001B[36m[Checkout]\u001B[0m Lấy code từ GitHub"
        // checkout scm
    //  }
   // }

    stage('Setup') {
      steps {
        echo "\u001B[36m[Setup]\u001B[0m Kiểm tra môi trường"
        sh '''#!/usr/bin/env bash
          set -eu
          mkdir -p "$LOG_DIR"

          {
            echo "== SETUP =="
            echo "DATE: $(date)"
            echo "WHOAMI: $(whoami)"
            echo "WORKSPACE: $(pwd)"
            echo "APP_DIR: $APP_DIR"
            echo "LOG_DIR: $LOG_DIR"
            docker --version
            docker-compose version
          } >> "$LOG_DIR/setup.log"

          printf "\\033[32m[OK]\\033[0m Setup OK\\n"
        '''
      }
    }

    stage('Deploy') {
      steps {
echo 'Copy file script mới nhất sang thư mục chạy...'
        // Lệnh này lấy file deploy.sh vừa tải về, ném sang thư mục đích
        sh 'cp deploy.sh /srv/devops-demo/'
        sh 'chmod +x /srv/devops-demo/deploy.sh' // Cấp quyền chạy cho chắc
        echo "\u001B[36m[Deploy]\u001B[0m Triển khai web"
        sh '''#!/usr/bin/env bash
          set -euo pipefail
          mkdir -p "$LOG_DIR"
          cd "$APP_DIR"

          if [[ ! -x scripts/deploy.sh ]]; then
            printf "\\033[31m[ERROR]\\033[0m Không tìm thấy scripts/deploy.sh hoặc chưa chmod +x\\n" >&2
            exit 1
          fi

          printf "\\033[33m[INFO]\\033[0m Chạy deploy.sh...\\n"
          ./scripts/deploy.sh
          printf "\\033[32m[OK]\\033[0m Deploy stage done\\n"
        '''
      }
    }

    stage('Monitor') {
      steps {
        echo "\u001B[36m[Monitor]\u001B[0m Health-check web"
        sh '''#!/usr/bin/env bash
          set -euo pipefail
          mkdir -p "$LOG_DIR"

          {
            echo "== MONITOR =="
            echo "DATE: $(date)"
          } >> "$LOG_DIR/monitor.log"

          # Yêu cầu HTTP 200
          if curl -fsS http://localhost >/dev/null; then
            printf "\\033[32m[OK]\\033[0m HTTP 200 OK\\n"
            echo "[OK] HTTP 200 OK" >> "$LOG_DIR/monitor.log"
          else
            printf "\\033[31m[ERROR]\\033[0m Health-check FAILED (http://localhost)\\n" >&2
            echo "[ERROR] Health-check FAILED (http://localhost)" >> "$LOG_DIR/monitor.log"
            exit 1
          fi
        '''
      }
    }
  }

  post {
    success {
      echo "\u001B[32m[SUCCESS]\u001B[0m Pipeline hoàn tất"
      sh '''#!/usr/bin/env bash
        set -eu
        mkdir -p "$LOG_DIR"
        echo "[SUCCESS] $(date)" >> "$LOG_DIR/pipeline.log"
      '''
    }

    failure {
      echo "\u001B[31m[FAILURE]\u001B[0m Pipeline thất bại – tóm tắt lỗi"
      sh '''#!/usr/bin/env bash
        set -eu
        mkdir -p "$LOG_DIR"

        echo "[FAILURE] $(date)" >> "$LOG_DIR/pipeline.log"

        echo "=== SUMMARY ==="
        echo "Time: $(date)"
        echo "APP_DIR: $APP_DIR"
        echo "LOG_DIR: $LOG_DIR"

        echo ""
        echo "--- Deploy log (last 25 lines) ---"
        tail -n 25 "$LOG_DIR/deploy.log" 2>/dev/null || echo "(deploy.log not found)"

        echo ""
        echo "--- Monitor log (last 15 lines) ---"
        tail -n 15 "$LOG_DIR/monitor.log" 2>/dev/null || echo "(monitor.log not found)"

        echo ""
        echo "--- Key errors (deploy.log) ---"
        grep -E "LỖI:|CẢNH BÁO:|\\[ERROR\\]|ERROR|Forbidden|Connection refused|Health-check FAILED" -n \
          "$LOG_DIR/deploy.log" 2>/dev/null | tail -n 20 || echo "(no matched errors)"
      '''
    }

    always {
      echo "\u001B[36m[POST]\u001B[0m Kết thúc pipeline"
      sh '''#!/usr/bin/env bash
        set -eu
        mkdir -p "$LOG_DIR"
        {
          echo "=============================="
          echo "PIPELINE RUN AT $(date)"
          echo "=============================="
        } >> "$LOG_DIR/pipeline.log"
      '''
    }
  }
}
