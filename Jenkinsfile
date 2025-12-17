pipeline {
  agent any

  stages {

    stage('Checkout') {
      steps {
        echo ' Lấy code từ GitHub...'
        checkout scm
      }
    }

    stage('Setup') {
      steps {
        echo ' Kiểm tra môi trường...'
        sh '''
          set -e
          docker --version
          docker compose version
          echo "[OK] Môi trường sẵn sàng"
        '''
      }
    }

    stage('Deploy') {
      steps {
        echo ' Triển khai web...'
        sh '''
          set -eux
          cd /srv/devops-demo
          ./scripts/deploy.sh
        '''
      }
    }

    stage('Monitor') {
      steps {
        echo ' Kiểm tra dịch vụ...'
        sh '''
          curl -fsS http://localhost >/dev/null
          echo "[OK] Web đang hoạt động"
        '''
      }
    }

  }

  post {
    success {
      echo ' PIPELINE THÀNH CÔNG – WEB ĐÃ ĐƯỢC CẬP NHẬT'
    }
    failure {
      echo 'PIPELINE THẤT BẠI – KIỂM TRA LOG'
    }
  }
}
