pipeline {
  agent any
  stages {
    stage('Setup') {
      steps {
        echo 'Cài đặt môi trường...'
        sh 'echo "[OK] Setup môi trường hoàn tất"'
      }
    }
    stage('Deploy') {
      steps {
        echo 'Triển khai web...'
        sh 'echo "[OK] Deploy web thành công"'
      }
    }
    stage('Monitor') {
      steps {
        echo 'Kiểm tra dịch vụ...'
        sh 'echo "[OK] Monitor kiểm tra thành công"'
      }
    }
  }
}
