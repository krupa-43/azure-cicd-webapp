pipeline {
    agent any

    environment {
        RESOURCE_GROUP = 'jenkins-rg'
        ACR_LOGIN_SERVER = 'kruparegistry353154903.azurecr.io'
        IMAGE_NAME = 'myapp'
        LOCATION = 'centralindia'
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'main',
                    url: 'https://github.com/krupa-43/azure-cicd-webapp.git'
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    // ✅ Define IMAGE_TAG as a global environment variable
                    env.IMAGE_TAG = sh(script: "git rev-parse --short HEAD", returnStdout: true).trim()
                    echo "Building Docker image with tag: ${env.IMAGE_TAG}"

                    sh """
                        docker build -t $ACR_LOGIN_SERVER/$IMAGE_NAME:latest .
                        docker tag $ACR_LOGIN_SERVER/$IMAGE_NAME:latest $ACR_LOGIN_SERVER/$IMAGE_NAME:${IMAGE_TAG}
                    """
                }
            }
        }

        stage('Login to ACR') {
            steps {
                withCredentials([
                    string(credentialsId: 'acr-username', variable: 'ACR_USERNAME'),
                    string(credentialsId: 'acr-password', variable: 'ACR_PASSWORD')
                ]) {
                    sh """
                        echo $ACR_PASSWORD | docker login $ACR_LOGIN_SERVER -u $ACR_USERNAME --password-stdin
                    """
                }
            }
        }

        stage('Push Docker Image') {
            steps {
                sh """
                    docker push $ACR_LOGIN_SERVER/$IMAGE_NAME:latest
                    docker push $ACR_LOGIN_SERVER/$IMAGE_NAME:${IMAGE_TAG}
                """
            }
        }

        stage('Deploy to Azure Container Instance') {
            steps {
                withCredentials([
                    string(credentialsId: 'acr-username', variable: 'ACR_USERNAME'),
                    string(credentialsId: 'acr-password', variable: 'ACR_PASSWORD')
                ]) {
                    sh """
                        echo "Deleting old container instance (if any)..."
                        az container delete --name myappcontainer --resource-group $RESOURCE_GROUP --yes || true

                        echo "Deploying new container with tag: ${IMAGE_TAG}"
                        az container create \
                            --resource-group $RESOURCE_GROUP \
                            --name myappcontainer \
                            --image $ACR_LOGIN_SERVER/$IMAGE_NAME:${IMAGE_TAG} \
                            --dns-name-label krupaapp$RANDOM \
                            --ports 80 \
                            --os-type Linux \
                            --cpu 1 \
                            --memory 1.5 \
                            --restart-policy Always \
                            --location $LOCATION \
                            --registry-login-server $ACR_LOGIN_SERVER \
                            --registry-username "$ACR_USERNAME" \
                            --registry-password "$ACR_PASSWORD" \
                            --image-pull-policy Always
                    """
                }
            }
        }

        stage('Verify Deployment') {
            steps {
                sh '''
                    echo "Checking running container image..."
                    az container show --name myappcontainer --resource-group $RESOURCE_GROUP --query "containers[].image" -o tsv
                '''
            }
        }
    }
}
