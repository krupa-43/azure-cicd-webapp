pipeline {
    agent any

    environment {
        ACR_LOGIN_SERVER = 'kruparegistry353154903.azurecr.io'
        IMAGE_NAME = 'myapp'
        RESOURCE_GROUP = 'jenkins-rg'
        LOCATION = 'centralindia'
    }

    stages {

        stage('Checkout Code') {
            steps {
                git branch: 'main',
                    credentialsId: 'github-krupa',
                    url: 'https://github.com/krupa-43/azure-cicd-webapp'
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    sh 'docker build -t $ACR_LOGIN_SERVER/$IMAGE_NAME:latest .'
                }
            }
        }

        stage('Login to Azure ACR') {
            steps {
                withCredentials([
                    string(credentialsId: 'acr-username', variable: 'ACR_USERNAME'),
                    string(credentialsId: 'acr-password', variable: 'ACR_PASSWORD')
                ]) {
                    sh '''
                        echo $ACR_PASSWORD | docker login $ACR_LOGIN_SERVER -u $ACR_USERNAME --password-stdin
                    '''
                }
            }
        }

        stage('Push Docker Image to ACR') {
            steps {
                sh 'docker push $ACR_LOGIN_SERVER/$IMAGE_NAME:latest'
            }
        }

        stage('Deploy to Azure Container Instance') {
            steps {
                withCredentials([
                    string(credentialsId: 'acr-username', variable: 'ACR_USERNAME'),
                    string(credentialsId: 'acr-password', variable: 'ACR_PASSWORD')
                ]) {
                    sh '''
                        az container create \
                            --resource-group $RESOURCE_GROUP \
                            --name myappcontainer \
                            --image $ACR_LOGIN_SERVER/$IMAGE_NAME:latest \
                            --dns-name-label krupaapp$RANDOM \
                            --ports 80 \
                            --os-type Linux \
                            --cpu 1 \
                            --memory 1.5 \
                            --restart-policy Always \
                            --location $LOCATION \
                            --registry-login-server $ACR_LOGIN_SERVER \
                            --registry-username "$ACR_USERNAME" \
                            --registry-password "$ACR_PASSWORD"
                    '''
                }
            }
        }
    }
}
