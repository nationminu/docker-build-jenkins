pipeline {
  environment {
    registry = "49.247.207.10:5000/jgtcom/jgtcom"
    registryCredential = 'registry'
  }
  agent any
  stages {
    stage('Cloning Git') {
      steps {
        git 'https://github.com/nationminu/docker-build-jenkins.git'
      }
    }
    stage('Building image') {
      steps{
        script {
          docker.build registry + ":$BUILD_NUMBER"
        }
      }
    }
  }
}
