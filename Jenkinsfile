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
          docker.withRegistry('http://49.247.207.10:5000', 'registry') {
              //docker.build '--network host' registry + ":$BUILD_NUMBER"
              def latestImage = docker.build(registry + ":$BUILD_NUMBER" , "--network host .")
              
              latestImage.push()
              latestImage.push('latest')
          } 
        }
      }
    }
    stage('Deploying Service') {
      steps {
         sh '''
            echo 'jgtcom!@#$' |docker login -u admin --password-stdin 49.247.207.10:5000
            '''
         //sh "docker service update jgtcom_jgtcom --image 49.247.207.10:5000/jgtcom/jgtcom:$BUILD_NUMBER --with-registry-auth --update-parallelism 1 --update-delay 300s --update-order start-first"
         sh "docker service update jgtcom_jgtcom --image 49.247.207.10:5000/jgtcom/jgtcom:$BUILD_NUMBER --with-registry-auth --update-delay 300s"
      }
    } 
  }
}
