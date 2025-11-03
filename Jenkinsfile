pipeline {
    agent any

    environment {
        // Azure Container Registry details
        ACR_LOGIN_SERVER = "kruparegistry353154903.azurecr.io"
        ACR_USERNAME = "kruparegistry353154903"
        // The ACR_PASSWORD is pulled from Jenkins credentials (securely)
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
                    // Get short commit hash for tagging
                    COMMIT_HASH = sh(script: 'git rev-parse --short HEAD', returnStdout: true).trim()
                    echo "Building Docker image with tag: ${COMMIT_HASH}"

                    sh """
                    docker build -t ${ACR_LOGIN_SERVER}/myapp:latest .
                    docker tag ${ACR_LOGIN_SERVER}/myapp:latest ${ACR_LOGIN_SERVER}/myapp:${COMMIT_HASH}
                    """
                }
            }
        }

        stage('Login to ACR') {
            steps {
                withCredentials([string(credentialsId: 'acr-password', variable: 'ACR_PASSWORD')]) {
                    sh """
                    echo ${ACR_PASSWORD} | docker login ${ACR_LOGIN_SERVER} -u ${ACR_USERNAME} --password-stdin
                    """
                }
            }
        }

        stage('Push Docker Image') {
            steps {
                script {
                    sh """
                    docker push ${ACR_LOGIN_SERVER}/myapp:latest
                    docker push ${ACR_LOGIN_SERVER}/myapp:${COMMIT_HASH}
                    """
                }
            }
        }

        stage('Deploy to Azure Container Instance') {
            steps {
                withCredentials([string(credentialsId: 'acr-password', variable: 'ACR_PASSWORD')]) {
                    script {
                        // Create a unique DNS name for the deployment
                        def dnsLabel = "krupaapp${new Random().nextInt(9999)}"
                        echo "Deploying container with DNS label: ${dnsLabel}"

                        sh """
                        az container create \
                          --resource-group krupa-rg \
                          --name myappcontainer \
                          --image ${ACR_LOGIN_SERVER}/myapp:${COMMIT_HASH} \
                          --dns-name-label ${dnsLabel} \
                          --ports 80 \
                          --os-type Linux \
                          --cpu 1 \
                          --memory 1.5 \
                          --restart-policy Always \
                          --location centralindia \
                          --registry-login-server ${ACR_LOGIN_SERVER} \
                          --registry-username ${ACR_USERNAME} \
                          --registry-password ${ACR_PASSWORD}
                        """
                    }
                }
            }
        }

        stage('Verify Deployment') {
            steps {
                script {
                    echo "Verifying Azure Container deployment..."
                    sh "az container show --resource-group krupa-rg --name myappcontainer --query ipAddress.fqdn -o tsv"
                }
            }
        }
    }

    post {
        success {
            echo "✅ Deployment successful! 🎉"
        }
        failure {
            echo "❌ Pipeline failed. Check the logs for details."
        }
    }
}
