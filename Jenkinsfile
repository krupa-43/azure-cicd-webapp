pipeline {
    agent any

    environment {
        ACR_NAME = 'kruparegistry353154903'
        ACR_LOGIN_SERVER = 'kruparegistry353154903.azurecr.io'
        IMAGE_NAME = 'myapp'
        RESOURCE_GROUP = 'jenkins-rg'
        LOCATION = 'centralindia'
        ACR_USERNAME = credentials('acr-username')
        ACR_PASSWORD = credentials('acr-password')
    }

    stages {
        stage('Checkout Code') {
            steps {
                git branch: 'main', url: 'https://github.com/krupa-43/azure-cicd-webapp.git'
            }
        }

        stage('Build Docker Image') {
            steps {
                sh 'docker build -t $ACR_LOGIN_SERVER/$IMAGE_NAME:latest .'
            }
        }

        stage('Login to ACR') {
            steps {
                sh 'echo $ACR_PASSWORD | docker login $ACR_LOGIN_SERVER -u $ACR_USERNAME --password-stdin'
            }
        }

        stage('Push to ACR') {
            steps {
                sh 'docker push $ACR_LOGIN_SERVER/$IMAGE_NAME:latest'
            }
        }

        stage('Deploy to Azure') {
            steps {
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
                    --registry-username $ACR_USERNAME \
                    --registry-password "$ACR_PASSWORD"
                '''
            }
        }
    }
}
