pipeline {
    agent any

    environment {
        ACR_NAME = 'myjenkinsacr1123328952'
        IMAGE_NAME = 'myapp'
        ACR_LOGIN_SERVER = "${ACR_NAME}.azurecr.io"
    }

    stages {
        stage('Checkout') {
            steps {
                git credentialsId: 'github-credentials', url: 'https://github.com/krupa-43/azure-cicd-webapp.git', branch: 'main'
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    docker.build("${ACR_LOGIN_SERVER}/${IMAGE_NAME}:latest")
                }
            }
        }

        stage('Login to ACR') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'acr-credentials', usernameVariable: 'USERNAME', passwordVariable: 'PASSWORD')]) {
                    sh "docker login ${ACR_LOGIN_SERVER} -u ${USERNAME} -p ${PASSWORD}"
                }
            }
        }

        stage('Push to ACR') {
            steps {
                sh "docker push ${ACR_LOGIN_SERVER}/${IMAGE_NAME}:latest"
            }
        }
    }

    post {
        success {
            echo 'Image pushed successfully to ACR!'
        }
        failure {
            echo 'Build failed!'
        }
    }
}
