pipeline {
    agent none
    environment {

        DEPLOY_VERSION = '0.0.2'
    }
    tools {
    maven 'maven-default' 
        }
    stages {
        stage('Build JAR') {
            agent any
            steps {
                sh 'mvn clean package -DskipTests'
                stash includes: 'target/*.jar', name: 'app' 
            }
        }
        stage('Build Docker, Save in Artifact Registry and Publish K8s') {
            agent {
                label 'dind-agent'
            }
            steps {
                configFileProvider(
                    [configFile(fileId: 'service-account-gcp', targetLocation: 'sa.json', variable: 'GOOGLE_APPLICATION_CREDENTIALS')]) 
                    { 
                        sh 'curl -O https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-cli-linux-x86_64.tar.gz'
                        sh 'tar -xf google-cloud-cli-linux-x86_64.tar.gz'
                        sh 'chmod u+x ./google-cloud-sdk'
                        sh './google-cloud-sdk/install.sh'
                        sh './google-cloud-sdk/bin/gcloud auth activate-service-account --key-file=$GOOGLE_APPLICATION_CREDENTIALS'
                    }
                unstash 'app'
                script{
                    
                    app = docker.build("razavala/hello-world", "--build-arg JAR_FILE=target/*.jar -f Dockerfile.jenkins .")
                    docker.withRegistry('https://registry.hub.docker.com', 'dockerhub'){
                        app.push("${env.DEPLOY_VERSION}")
                        app.push("latest")
                    }
                  sh 'curl -LO "https://storage.googleapis.com/kubernetes-release/release/v1.20.5/bin/linux/amd64/kubectl"'
                  sh 'chmod u+x ./kubectl'
                  sh """
                        export PATH=/home/jenkins/agent/workspace/Devlopment-Hello-World/google-cloud-sdk/bin:$PATH
                        gcloud components install kubectl
                        gcloud container clusters get-credentials development --region us-east1 --project devops-cus
                        ./kubectl apply -f k8s.yml -n hello
                    """
                    }
                }
            }
        }
    }