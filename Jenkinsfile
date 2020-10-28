pipeline {

  agent any

  environment {
    CRASHTEST_WEBHOOK = credentials('crashtest-webhook')
  }

  stages {
    stage('Run Crashtest Security Scan') {
      steps {
        sh 'bash start_crashtest_jenkins.sh $CRASHTEST_WEBHOOK'
      }
    }
  }

  post {
    always {
      junit 'report.xml'
    }
  }

}