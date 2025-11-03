pipeline {
    agent any

    environment {
        ACR_NAME = 'kruparegistry353154903'
        ACR_LOGIN_SERVER = "${ACR_NAME}.azurecr.io"
        RESOURCE_GROUP = 'krupa-rg'
        CONTAINER_NAME = 'myappcontainer'
        DNS_LABEL = 'krupaapp4023'
        LOCATION = 'centralindia'
        IMAGE_NAME = 'myapp'
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
                    def commitHash = sh(script: "git rev-parse --short HEAD", returnStdout: true).trim()
                    echo "Building Docker image with tag: ${commitHash}"
                    sh "docker build -t ${ACR_LOGIN_SERVER}/${IMAGE_NAME}:latest ."
                    sh "docker tag ${ACR_LOGIN_SERVER}/${IMAGE_NAME}:latest ${ACR_LOGIN_SERVER}/${IMAGE_NAME}:${commitHash}"
                    env.COMMIT_HASH = commitHash
                }
            }
        }

        stage('Login to ACR') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'acr-credentials', usernameVariable: 'ACR_USERNAME', passwordVariable: 'ACR_PASSWORD')]) {
                    sh """
                        echo \$ACR_PASSWORD | docker login ${ACR_LOGIN_SERVER} -u \$ACR_USERNAME --password-stdin
                    """
                }
            }
        }

        stage('Push Docker Image') {
            steps {
                script {
                    sh "docker push ${ACR_LOGIN_SERVER}/${IMAGE_NAME}:latest"
                    sh "docker push ${ACR_LOGIN_SERVER}/${IMAGE_NAME}:${env.COMMIT_HASH}"
                }
            }
        }

        stage('Deploy to Azure Container Instance') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'acr-credentials', usernameVariable: 'ACR_USERNAME', passwordVariable: 'ACR_PASSWORD')]) {
                    script {
                        echo "Deploying container with DNS label: ${DNS_LABEL}"

                        // Ensure resource group exists
                        sh """
                            az group create --name ${RESOURCE_GROUP} --location ${LOCATION}
                        """

                        // Delete old container (if it exists)
                        sh """
                            if az container show --resource-group ${RESOURCE_GROUP} --name ${CONTAINER_NAME} &>/dev/null; then
                                echo "Old container found. Deleting..."
                                az container delete --resource-group ${RESOURCE_GROUP} --name ${CONTAINER_NAME} --yes
                            fi
                        """

                        // Deploy new container
                        sh """
                            az container create \
                                --resource-group ${RESOURCE_GROUP} \
                                --name ${CONTAINER_NAME} \
                                --image ${ACR_LOGIN_SERVER}/${IMAGE_NAME}:${env.COMMIT_HASH} \
                                --dns-name-label ${DNS_LABEL} \
                                --ports 80 \
                                --os-type Linux \
                                --cpu 1 \
                                --memory 1.5 \
                                --restart-policy Always \
                                --location ${LOCATION} \
                                --registry-login-server ${ACR_LOGIN_SERVER} \
                                --registry-username \$ACR_USERNAME \
                                --registry-password \$ACR_PASSWORD
                        """
                    }
                }
            }
        }

        stage('Verify Deployment') {
            steps {
                script {
                    echo "✅ Deployment completed! Access your app at: http://${DNS_LABEL}.${LOCATION}.azurecontainer.io"
                }
            }
        }
    }

    post {
        success {
            echo "🎉 Pipeline completed successfully!"
        }
        failure {
            echo "❌ Pipeline failed. Check the logs for details."
        }
    }
}
