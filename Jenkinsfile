pipeline {
    agent none
    environment {

        DEPLOY_VERSION = '0.0.1'

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
                sh 'pwd'
          //     sh 'sleep 15'
                configFileProvider(
                    [configFile(fileId: 'service-account-gcp', targetLocation: 'sa.json', variable: 'GOOGLE_APPLICATION_CREDENTIALS')]) 
                    {
                        sh 'curl -O https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-cli-linux-x86_64.tar.gz'
                        sh 'tar -xf google-cloud-cli-linux-x86_64.tar.gz'
                        sh './google-cloud-sdk/install.sh'
                        sh 'cp /google-cloud-sdk/bin/gcloud /usr/local/bin/gcloud'
                        sh 'ls -l /usr/local/bin/ '
                        sh 'gcloud auth activate-service-account --key-file=$GOOGLE_APPLICATION_CREDENTIALS'
                    //    sh './google-cloud-sdk/bin/gcloud auth configure-docker us-east1-docker.pkg.dev'
                    //    sh 'export DOCKER_CONFIG=/home/jenkins/.docker'
                    }
                unstash 'app'

                //sh "docker build -t us-east1-docker.pkg.dev/devops-cus/devops-test/hello-world:${env.DEPLOY_VERSION} --build-arg JAR_FILE=target/*.jar -f Dockerfile.jenkins ."
                //sh "docker push us-east1-docker.pkg.dev/devops-cus/devops-test/hello-world:${env.DEPLOY_VERSION}"
                script{
                    
                    app = docker.build("razavala/hello-world", "--build-arg JAR_FILE=target/*.jar -f Dockerfile.jenkins .")
                    docker.withRegistry('https://registry.hub.docker.com', 'dockerhub'){
                        app.push("${env.DEPLOY_VERSION}")
                        app.push("latest")
                    }
                  sh 'curl -LO "https://storage.googleapis.com/kubernetes-release/release/v1.20.5/bin/linux/amd64/kubectl"'
                  sh 'chmod u+x ./kubectl'  
                  sh './google-cloud-sdk/bin/gcloud components install kubectl'
                  sh './google-cloud-sdk/bin/gcloud container clusters get-credentials development --region us-east1 --project devops-cus'
                  sh "./kubectl get pods -n hello"
                    }
                }
            }
        }
    }