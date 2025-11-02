pipeline {
    agent any

    environment {
        ACR_NAME = 'krupaacr'               // your Azure Container Registry name
        RESOURCE_GROUP = 'krupa-rg'         // your Azure Resource Group name
        APP_NAME = 'krupa-webapp'           // your Azure Web App name
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/krupa-43/azure-cicd-webapp.git'
            }
        }

        stage('Build Docker Image') {
            steps {
                sh 'docker build -t azure-cicd-app .'
            }
        }

        stage('Login to Azure & Push Image') {
            steps {
                sh '''
                az login --service-principal -u $AZURE_CLIENT_ID -p $AZURE_CLIENT_SECRET --tenant $AZURE_TENANT_ID
                az acr login --name $ACR_NAME
                docker tag azure-cicd-app $ACR_NAME.azurecr.io/azure-cicd-app:latest
                docker push $ACR_NAME.azurecr.io/azure-cicd-app:latest
                '''
            }
        }

        stage('Deploy to Azure Web App') {
            steps {
                sh '''
                az webapp config container set --name $APP_NAME --resource-group $RESOURCE_GROUP \
                    --docker-custom-image-name $ACR_NAME.azurecr.io/azure-cicd-app:latest \
                    --docker-registry-server-url https://$ACR_NAME.azurecr.io
                '''
            }
        }
    }
}
