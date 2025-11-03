pipeline {
    agent any

    environment {
        ACR_NAME = 'kruparegistry353154903'
        ACR_LOGIN_SERVER = "${ACR_NAME}.azurecr.io"
        IMAGE_NAME = 'myapp'
        RESOURCE_GROUP = 'krupa-rg'
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
                    COMMIT_HASH = sh(script: 'git rev-parse --short HEAD', returnStdout: true).trim()
                    echo "Building Docker image with tag: ${COMMIT_HASH}"
                    sh "docker build -t ${ACR_LOGIN_SERVER}/${IMAGE_NAME}:latest ."
                    sh "docker tag ${ACR_LOGIN_SERVER}/${IMAGE_NAME}:latest ${ACR_LOGIN_SERVER}/${IMAGE_NAME}:${COMMIT_HASH}"
                }
            }
        }

        stage('Login to ACR') {
            steps {
                withCredentials([
                    usernamePassword(credentialsId: 'acr-credentials', passwordVariable: 'ACR_PASSWORD', usernameVariable: 'ACR_USERNAME')
                ]) {
                    sh """
                        echo ${ACR_PASSWORD} | docker login ${ACR_LOGIN_SERVER} -u ${ACR_USERNAME} --password-stdin
                    """
                }
            }
        }

        stage('Push Docker Image') {
            steps {
                script {
                    sh "docker push ${ACR_LOGIN_SERVER}/${IMAGE_NAME}:latest"
                    sh "docker push ${ACR_LOGIN_SERVER}/${IMAGE_NAME}:${COMMIT_HASH}"
                }
            }
        }

        stage('Deploy to Azure Container Instance') {
            steps {
                withCredentials([
                    usernamePassword(credentialsId: 'acr-credentials', passwordVariable: 'ACR_PASSWORD', usernameVariable: 'ACR_USERNAME')
                ]) {
                    script {
                        // Generate random label for DNS
                        def randomLabel = "krupaapp${new Random().nextInt(10000)}"
                        echo "Deploying container with DNS label: ${randomLabel}"

                        sh """
                            az container create \
                                --resource-group ${RESOURCE_GROUP} \
                                --name myappcontainer \
                                --image ${ACR_LOGIN_SERVER}/${IMAGE_NAME}:${COMMIT_HASH} \
                                --dns-name-label ${randomLabel} \
                                --ports 80 \
                                --os-type Linux \
                                --cpu 1 \
                                --memory 1.5 \
                                --restart-policy Always \
                                --location ${LOCATION} \
                                --registry-login-server ${ACR_LOGIN_SERVER} \
                                --registry-username "${ACR_USERNAME}" \
                                --registry-password "${ACR_PASSWORD}" \
                                --image-pull-policy Always
                        """

                        // Store DNS label for next stage
                        env.APP_DNS = randomLabel
                    }
                }
            }
        }

        stage('Verify Deployment') {
            steps {
                script {
                    echo "Deployment completed successfully!"
                    echo "Your app is available at: http://${APP_DNS}.${LOCATION}.azurecontainer.io"
                }
            }
        }
    }
}
