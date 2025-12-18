pipeline {
  agent any

  options {
    timestamps()               // Timestamp cho từng dòng log
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
        sh '''
          set -eux
          mkdir -p "$LOG_DIR"
          {
            echo "== SETUP STAGE =="
            echo "DATE: $(date)"
            echo "WHOAMI: $(whoami)"
            echo "PWD: $(pwd)"
            docker --version
            docker compose version
          } | tee -a "$LOG_DIR/setup.log"
        '''
      }
    }

   stage('Deploy') {
  steps {
    echo '[Deploy] Triển khai web'
    sh '''
      set -euxo pipefail

      mkdir -p "$LOG_DIR"
      cd "$APP_DIR"

      {
        echo "== DEPLOY STAGE =="
        echo "DATE: $(date)"
        ls -la
        test -x scripts/deploy.sh
        ./scripts/deploy.sh
      } | tee -a "$LOG_DIR/deploy.log"
    '''
  }
}

    stage('Monitor') {
      steps {
        echo '[Monitor] Kiểm tra dịch vụ'
        sh '''
          set -eux
          mkdir -p "$LOG_DIR"
          {
            echo "== MONITOR STAGE =="
            echo "DATE: $(date)"
           curl -fsS http://localhost >/dev/null
          } | tee -a "$LOG_DIR/monitor.log"
        '''
      }
    }
  }

  post {
    success {
      echo '[SUCCESS] Pipeline hoàn tất – Web hoạt động bình thường'
      sh '''
        mkdir -p "$LOG_DIR"
        echo "Pipeline SUCCESS at $(date)" | tee -a "$LOG_DIR/pipeline.log"
      '''
    }

    failure {
      echo '[FAILURE] Pipeline thất bại – xem log chi tiết'
      sh '''
        mkdir -p "$LOG_DIR"
        echo "Pipeline FAILED at $(date)" | tee -a "$LOG_DIR/pipeline.log"
        echo "---- Tail deploy.log ----" | tee -a "$LOG_DIR/pipeline.log"
        tail -n 80 "$LOG_DIR/deploy.log" 2>/dev/null | tee -a "$LOG_DIR/pipeline.log" || true
        echo "---- Tail monitor.log ----" | tee -a "$LOG_DIR/pipeline.log"
        tail -n 80 "$LOG_DIR/monitor.log" 2>/dev/null | tee -a "$LOG_DIR/pipeline.log" || true
      '''
    }

    always {
      echo '[POST] Kết thúc pipeline'
      sh '''
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
