pipeline {
    agent any

    environment {
        ACR_NAME = "myjenkinsacr1123328952"
        IMAGE_NAME = "myapp"
        IMAGE_TAG = "latest"
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/krupa-43/azure-cicd-webapp.git'
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    sh 'docker build -t ${ACR_NAME}.azurecr.io/${IMAGE_NAME}:${IMAGE_TAG} .'
                }
            }
        }

        stage('Login to ACR') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'acr-credentials2', usernameVariable: 'USERNAME', passwordVariable: 'PASSWORD')]) {
                    sh '''
                        echo $PASSWORD | docker login ${ACR_NAME}.azurecr.io -u $USERNAME --password-stdin
                    '''
                }
            }
        }

        stage('Push to ACR') {
            steps {
                script {
                    sh '''
                        docker push ${ACR_NAME}.azurecr.io/${IMAGE_NAME}:${IMAGE_TAG}
                    '''
                }
            }
        }
    }

    post {
        success {
            echo '✅ Docker image pushed to ACR successfully!'
        }
        failure {
            echo '❌ Build failed!'
        }
    }
}
