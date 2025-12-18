pipeline {
  agent any

  options {
    timestamps()
  }

  environment {
    APP_DIR = "/srv/devops-demo"
    LOG_DIR = "/srv/devops-demo/logs"
  }

  stages {

    stage('Checkout') {
      steps {
        echo '[Checkout] Lấy code từ GitHub'
        checkout scm
      }
    }

    stage('Setup') {
      steps {
        echo '[Setup] Kiểm tra môi trường'
        sh '''#!/usr/bin/env bash
          set -eu
          mkdir -p "$LOG_DIR"

          echo "== SETUP =="
          echo "DATE: $(date)"
          echo "WHOAMI: $(whoami)"
          echo "WORKSPACE: $(pwd)"
          echo "APP_DIR: $APP_DIR"
          echo "LOG_DIR: $LOG_DIR"

          command -v docker >/dev/null
          docker --version
          docker compose version
        '''
      }
    }

    stage('Deploy') {
      steps {
        echo '[Deploy] Triển khai web'
        sh '''#!/usr/bin/env bash
          set -euo pipefail
          mkdir -p "$LOG_DIR"
          cd "$APP_DIR"

          test -x scripts/deploy.sh

          # Chạy deploy (deploy.sh tự exit 1 nếu fail)
          ./scripts/deploy.sh
        '''
      }
    }

    stage('Monitor') {
      steps {
        echo '[Monitor] Health-check web'
        sh '''#!/usr/bin/env bash
          set -euo pipefail
          mkdir -p "$LOG_DIR"

          echo "== MONITOR =="
          echo "DATE: $(date)"

          # Yêu cầu HTTP 200 (curl -f sẽ fail nếu 403/404/500)
          curl -fsS http://localhost >/dev/null

          echo "HTTP OK ✅"
        '''
      }
    }
  }

  post {
    success {
      echo '[SUCCESS] Pipeline hoàn tất'
      sh '''#!/usr/bin/env bash
        set -eu
        mkdir -p "$LOG_DIR"
        echo "[SUCCESS] $(date)" >> "$LOG_DIR/pipeline.log"
      '''
    }

    failure {
      echo '[FAILURE] Pipeline thất bại – tóm tắt lỗi'
      sh '''#!/usr/bin/env bash
        set -eu
        mkdir -p "$LOG_DIR"

        echo "[FAILURE] $(date)" >> "$LOG_DIR/pipeline.log"

        echo "=== SUMMARY ==="
        echo "Time: $(date)"
        echo "APP_DIR: $APP_DIR"
        echo "LOG_DIR: $LOG_DIR"

        echo ""
        echo "--- Deploy log (last 30 lines) ---"
        tail -n 30 "$LOG_DIR/deploy.log" 2>/dev/null || echo "(deploy.log not found)"

        echo ""
        echo "--- Monitor log (last 20 lines) ---"
        tail -n 20 "$LOG_DIR/monitor.log" 2>/dev/null || echo "(monitor.log not found)"

        echo ""
        echo "--- Key errors (deploy.log) ---"
        grep -E "LỖI:|CẢNH BÁO:|ERROR|Forbidden|Connection refused|exit code" -n \
          "$LOG_DIR/deploy.log" 2>/dev/null | tail -n 30 || echo "(no matched errors)"
      '''
    }

    always {
      echo '[POST] Kết thúc pipeline'
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
