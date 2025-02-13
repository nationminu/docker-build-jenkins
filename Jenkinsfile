// Jenkinsfile for pipeline
// pipeline

pipeline {
  agent {
    kubernetes {
      // Kubernetes Pod 정의
      yaml '''
apiVersion: v1
kind: Pod
metadata:
  name: buildah
spec:
  containers:
  - name: buildah
    image: quay.io/buildah/stable:v1.38.0
    command:
    - cat
    tty: true
    securityContext:
      privileged: true
    volumeMounts:
      - name: varlibcontainers
        mountPath: /var/lib/containers
  volumes:
    - name: varlibcontainers
'''
    }
  }

  options {
    // 빌드 기록 유지 정책 설정 (최근 3개 빌드만 유지)
    buildDiscarder(logRotator(numToKeepStr: '3'))
    // 파이프라인 성능 최적화
    durabilityHint('PERFORMANCE_OPTIMIZED')
    // 동시 빌드 방지
    disableConcurrentBuilds()
  }

  environment {
    // 컨테이너 레지스트리 인증 정보
    ND_CREDS=credentials('nexus-dev')
    // 컨테이너 레지스트리 호스트
    REGISTRY_HOST="svc.registry.svc.cluster.local"
    // 이미지 네임스페이스
    IMAGE_NAMESPACE="library"
    // 이미지 이름
    SHORT_IMAGE_NAME="nginx"
  }

  stages {
    // Stage 1: 환경 변수 설정
    stage('환경 변수 재정의 - Prepare') {
      steps {
        script {
          try {
            // Dockerfile 위치 설정
            def dockerfile = './docker/Dockerfile'
            env.DOCKER_FILE_LOCATION = dockerfile

            // 이미지 버전 및 태그 설정(STABLE)
            def imageName = "${env.IMAGE_NAMESPACE}/${env.SHORT_IMAGE_NAME}" // 이미지 이름
            def imageTag = "${env.IMAGE_BUILD_VERSION}" // 이미지 태그 환경변수

            // 환경 변수에 이미지 정보 저장
            env.IMAGE_NAME = "${imageName}"
            env.IMAGE_TAG = "${imageTag}"
            env.FULL_IMAGE_NAME = "${imageName}:${imageTag}"
          } catch (Exception e) {
            echo "환경 변수 설정 중 오류 발생: ${e}"
            currentBuild.result = 'FAILURE'
            error("파이프라인 중단")
          }
        }
      }
    }

    // Stage 2: 환경 변수 출력
    stage('환경변수 확인 - printenv') {
      steps {
        container('buildah') {
          script {
            try {
              // 환경 변수 출력
              def envOutput = sh(script: 'env | sort', returnStdout: true).trim()
              echo "환경 변수:\n${envOutput}"
            } catch (Exception e) {
              echo "환경 변수 확인 중 오류 발생: ${e}"
              currentBuild.result = 'FAILURE'
              error("파이프라인 중단")
            }
          }
        }
      }
    }

    // Stage 3: 소스 코드 체크아웃
    stage('소스 체크아웃 - Git Checkout') {
      steps {
        container('buildah') {
          script {
            try {
              // Git 리포지토리에서 소스 코드 체크아웃
              git branch: 'main', // Git 브랜치
                credentialsId: 'gitlab-local', // Git 자격 증명
                url: 'http://svc.gitlab.svc.cluster.local/sample/application.git' // Git 저장소 URL
            } catch (Exception e) {
              echo "소스 체크아웃 중 오류 발생: ${e}"
              currentBuild.result = 'FAILURE'
              error("파이프라인 중단")
            }
          }
        }
      }
    }

    // Stage 4: 컨테이너 이미지 빌드 및 Annotation 추가
    stage('컨테이너 이미지 빌드 - Build with Buildah') {
      steps {
        container('buildah') {
          script {
            try {
              // 1. 이미지 빌드
              sh """
                buildah build -t ${env.REGISTRY_HOST}/${env.FULL_IMAGE_NAME} -f ${env.DOCKER_FILE_LOCATION} .
              """

              // 2. 컨테이너 ID 가져오기
              def containerId = sh(script: "buildah from ${env.REGISTRY_HOST}/${env.FULL_IMAGE_NAME}", returnStdout: true).trim()
              echo "컨테이너 ID: ${containerId}"

              // 3. 이미지에 Annotation 추가
              sh """
                buildah config --annotation "build.date=\$(date +'%Y-%m-%d')" ${containerId}
                buildah config --annotation "build.version=${env.IMAGE_TAG}" ${containerId}
                buildah config --annotation "build.id=${env.BUILD_ID}" ${containerId}
                buildah config --annotation "build.comment=This image was built by Jenkins Pipeline on \$(date +'%Y-%m-%d %H:%M:%S')" ${containerId}
              """

              // 4. 컨테이너를 커밋하여 최종 이미지 생성
              sh """
                buildah commit ${containerId} ${env.REGISTRY_HOST}/${env.FULL_IMAGE_NAME}
              """
            } catch (Exception e) {
              echo "이미지 빌드 또는 메타데이터 설정 중 오류 발생: ${e}"
              currentBuild.result = 'FAILURE'
              error("파이프라인 중단")
            }
          }
        }
      }
    }

    // Stage 5: 레지스트리 로그인
    stage('컨테이너 레지스트리 접속 - Login to Docker Hub') {
      steps {
        container('buildah') {
          script {
            try {
              // Docker Hub에 로그인
              sh """
                echo ${ND_CREDS_PSW} | buildah login -u ${ND_CREDS_USR} --password-stdin ${env.REGISTRY_HOST}
              """
            } catch (Exception e) {
              echo "레지스트리 로그인 중 오류 발생: ${e}"
              currentBuild.result = 'FAILURE'
              error("파이프라인 중단")
            }
          }
        }
      }
    }

    // Stage 6: 이미지 태깅 (STABLE 버전인 경우)
    stage('컨테이너 이미지 태깅 - Tag image') {
      // when { expression { return env.BUILD_VERSION == 'STABLE'} } // STABLE 버전인 경우만 실행
      steps {
        container('buildah') {
          script {
            try {
              // 이미지 태깅
              sh """
                buildah tag ${env.REGISTRY_HOST}/${env.FULL_IMAGE_NAME} ${env.REGISTRY_HOST}/${env.IMAGE_NAME}:latest
              """
            } catch (Exception e) {
              echo "이미지 태깅 중 오류 발생: ${e}"
              currentBuild.result = 'FAILURE'
              error("파이프라인 중단")
            }
          }
        }
      }
    }

    // Stage 7: 이미지 푸시
    stage('컨테이너 이미지 푸시 - Push image') {
      steps {
        container('buildah') {
          script {
            try {
              // 빌드한 이미지를 레지스트리에 푸시
              sh """
                buildah push ${env.REGISTRY_HOST}/${env.FULL_IMAGE_NAME}
                buildah push ${env.REGISTRY_HOST}/${env.IMAGE_NAME}:latest
              """
            } catch (Exception e) {
              echo "이미지 푸시 중 오류 발생: ${e}"
              currentBuild.result = 'FAILURE'
              error("파이프라인 중단")
            }
          }
        }
      }
    }
  }

  // Post Actions: 빌드 후 처리
  post {
    always {
      container('buildah') {
        script {
          try {
            // 레지스트리 로그아웃
            sh """
              buildah logout ${REGISTRY_HOST}
            """
          } catch (Exception e) {
            echo "레지스트리 로그아웃 중 오류 발생: ${e}"
          }
        }
      }
    }
    aborted {
      // 빌드가 승인되지 않았을 때 메시지 출력
      echo "빌드가 승인되지 않았습니다. 빌드를 종료합니다."
    }
    failure {
      // 빌드 실패 시 메시지 출력
      echo "빌드가 실패했습니다. 자세한 내용은 로그를 확인하세요."
    }
    success {
      // 빌드 성공 시 메시지 출력
      echo "빌드가 성공적으로 완료되었습니다."
      echo "이미지: ${env.REGISTRY_HOST}/${env.FULL_IMAGE_NAME}"
    }
  }
}
