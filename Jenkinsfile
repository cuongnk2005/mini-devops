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
        
        sh 'mkdir -p /srv/devops-demo/scripts' 
        
        sh 'cp scripts/setup.sh /srv/devops-demo/scripts/setup.sh'
        sh 'chmod +x /srv/devops-demo/scripts/setup.sh'
        
        sh '/srv/devops-demo/scripts/setup.sh'
      }
    }

    stage('Deploy') {
      steps {
        echo "Copy deploy.sh mới nhất sang server..."
        
        sh '''#!/usr/bin/env bash
          set -euo pipefail

          mkdir -p "$APP_DIR/scripts"

          cp -f scripts/deploy.sh "$APP_DIR/scripts/deploy.sh"
          chmod +x "$APP_DIR/scripts/deploy.sh"

          export WORKSPACE_DIR="$WORKSPACE"

          echo "Đang khởi chạy deploy script..."
          
          "$APP_DIR/scripts/deploy.sh"
        '''
      }
    }

    stage('Monitor') {
      steps {
        echo "\u001B[36m[Monitor]\u001B[0m Health-check web"
        sh '''#!/usr/bin/env bash
          set -euo pipefail
          
          # 1. Tạo thư mục scripts (nếu chưa có)
          mkdir -p "$APP_DIR/scripts"

          # 2. Copy file monitor vào đó
          cp -f scripts/monitor.sh "$APP_DIR/scripts/monitor.sh"
          
          # 3. Cấp quyền chạy
          chmod +x "$APP_DIR/scripts/monitor.sh"
          
          # 4. Chạy file monitor
          "$APP_DIR/scripts/monitor.sh"
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
