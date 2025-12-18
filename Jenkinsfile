pipeline {
  agent any

  options {
    timestamps()               // Gắn timestamp cho từng dòng log
    ansiColor('xterm')         // Log dễ đọc (nếu có plugin)
  }

  environment {
    APP_DIR = "/srv/devops-demo"
    LOG_DIR = "/srv/devops-demo/logs"
    PIPELINE_LOG = "/srv/devops-demo/logs/pipeline.log"
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
        sh '''
          set -eux
          mkdir -p logs
          {
            echo "== SETUP STAGE =="
            docker --version
            docker compose version
          } | tee -a logs/setup.log
        '''
      }
    }

    stage('Deploy') {
      steps {
        echo '[Deploy] Triển khai web'
        sh '''
          set -eux
          cd /srv/devops-demo
          {
            echo "== DEPLOY STAGE =="
            ./scripts/deploy.sh
          } | tee -a logs/deploy.log
        '''
      }
    }

    stage('Monitor') {
      steps {
        echo '[Monitor] Kiểm tra dịch vụ'
        sh '''
          set -eux
          {
            echo "== MONITOR STAGE =="
            curl -v http://localhost
          } | tee -a logs/monitor.log
        '''
      }
    }

  }

  post {
    success {
      echo '[SUCCESS] Pipeline hoàn tất – Web hoạt động bình thường'
      sh '''
        echo "Pipeline SUCCESS at $(date)" >> /srv/devops-demo/logs/pipeline.log
      '''
    }

    failure {
      echo '[FAILURE] Pipeline thất bại – xem log chi tiết'
      sh '''
        echo "Pipeline FAILED at $(date)" >> /srv/devops-demo/logs/pipeline.log
      '''
    }

    always {
      echo '[POST] Tổng hợp log'
      sh '''
        {
          echo "=============================="
          echo "PIPELINE RUN AT $(date)"
          echo "=============================="
        } >> /srv/devops-demo/logs/pipeline.log
      '''
    }
  }
}
