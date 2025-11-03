pipeline {
    agent any

    environment {
        RESOURCE_GROUP = 'jenkins-rg'
        ACR_NAME = 'kruparegistry353154903'
        IMAGE_NAME = 'myapp'
        LOCATION = 'centralindia'
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
                    def COMMIT_HASH = sh(returnStdout: true, script: "git rev-parse --short HEAD").trim()
                    echo "Building Docker image with tag: ${COMMIT_HASH}"

                    sh """
                        docker build -t ${ACR_NAME}.azurecr.io/${IMAGE_NAME}:latest .
                        docker tag ${ACR_NAME}.azurecr.io/${IMAGE_NAME}:latest ${ACR_NAME}.azurecr.io/${IMAGE_NAME}:${COMMIT_HASH}
                    """
                }
            }
        }

        stage('Login to ACR') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'acr-username', usernameVariable: 'ACR_USERNAME', passwordVariable: 'ACR_PASSWORD')]) {
                    sh """
                        echo ${ACR_PASSWORD} | docker login ${ACR_NAME}.azurecr.io -u ${ACR_USERNAME} --password-stdin
                    """
                }
            }
        }

        stage('Push Docker Image') {
            steps {
                script {
                    def COMMIT_HASH = sh(returnStdout: true, script: "git rev-parse --short HEAD").trim()
                    sh """
                        docker push ${ACR_NAME}.azurecr.io/${IMAGE_NAME}:latest
                        docker push ${ACR_NAME}.azurecr.io/${IMAGE_NAME}:${COMMIT_HASH}
                    """
                }
            }
        }

        stage('Deploy to Azure Container Instance') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'acr-username', usernameVariable: 'ACR_USERNAME', passwordVariable: 'ACR_PASSWORD')]) {
                    script {
                        def COMMIT_HASH = sh(returnStdout: true, script: "git rev-parse --short HEAD").trim()
                        def DNS_LABEL = "krupaapp${env.BUILD_NUMBER}"

                        echo "Deploying container with DNS label: ${DNS_LABEL}"

                        // Try deployment and rollback if needed
                        try {
                            sh """
                                az container create \
                                  --resource-group ${RESOURCE_GROUP} \
                                  --name myappcontainer \
                                  --image ${ACR_NAME}.azurecr.io/${IMAGE_NAME}:${COMMIT_HASH} \
                                  --dns-name-label ${DNS_LABEL} \
                                  --ports 80 \
                                  --os-type Linux \
                                  --cpu 1 \
                                  --memory 1.5 \
                                  --restart-policy Always \
                                  --location ${LOCATION} \
                                  --registry-login-server ${ACR_NAME}.azurecr.io \
                                  --registry-username ${ACR_USERNAME} \
                                  --registry-password ${ACR_PASSWORD}
                            """
                        } catch (err) {
                            echo "❌ Deployment failed. Rolling back to previous image..."
                            sh """
                                az container create \
                                  --resource-group ${RESOURCE_GROUP} \
                                  --name myappcontainer \
                                  --image ${ACR_NAME}.azurecr.io/${IMAGE_NAME}:latest \
                                  --dns-name-label ${DNS_LABEL}-rollback \
                                  --ports 80 \
                                  --os-type Linux \
                                  --cpu 1 \
                                  --memory 1.5 \
                                  --restart-policy Always \
                                  --location ${LOCATION} \
                                  --registry-login-server ${ACR_NAME}.azurecr.io \
                                  --registry-username ${ACR_USERNAME} \
                                  --registry-password ${ACR_PASSWORD}
                            """
                            error("Deployment failed and rollback executed.")
                        }
                    }
                }
            }
        }

        stage('Verify Deployment') {
            steps {
                echo "✅ Deployment completed successfully. Verify the container in Azure Portal under Container Instances."
            }
        }
    }

    post {
        success {
            echo '✅ Pipeline completed successfully.'
        }
        failure {
            echo '❌ Pipeline failed. Check the logs for details.'
        }
    }
}
