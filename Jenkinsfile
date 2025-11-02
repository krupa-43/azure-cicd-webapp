pipeline {
    agent any

    environment {
        ACR_LOGIN_SERVER = 'mycontainerregistrykrupa.azurecr.io'
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/krupa-43/azure-cicd-webapp'
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    dockerImage = docker.build("${ACR_LOGIN_SERVER}/myapp:${BUILD_NUMBER}")
                }
            }
        }

        stage('Push to Azure Container Registry') {
            steps {
                script {
                    withCredentials([usernamePassword(credentialsId: 'acr-credentials', usernameVariable: 'USERNAME', passwordVariable: 'PASSWORD')]) {
                        sh """
                        echo $PASSWORD | docker login $ACR_LOGIN_SERVER -u $USERNAME --password-stdin
                        docker push ${ACR_LOGIN_SERVER}/myapp:${BUILD_NUMBER}
                        docker logout $ACR_LOGIN_SERVER
                        """
                    }
                }
            }
        }
    }
}
