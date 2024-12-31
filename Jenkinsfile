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
        stage('Build Docker, Save in ECR and Publish K8s') {
            agent {
                label 'dind-agent'
            }
            steps {
                unstash 'app'
                sh 'sleep 15'
//                script{
//                    
//                    app = docker.build("setrass-ecms-inspection-svc", "--build-arg JAR_FILE=target/*.jar -f Dockerfile.jenkins .")
//                    docker.withRegistry('https://648505502080.dkr.ecr.us-east-1.amazonaws.com', 'ecr:us-east-1:aws-credentials'){
//                        app.push("${env.DEPLOY_VERSION}")
//                        app.push("latest")
//                    }
//                sh 'curl -LO "https://storage.googleapis.com/kubernetes-release/release/v1.20.5/bin/linux/amd64/kubectl"'
//                sh 'chmod u+x ./kubectl'  
//                if (env.ENTORNO == 'development') {
//                    withAWS(credentials: 'aws-credentials', region: 'us-east-1') {
//                        script {
//                            sh ('aws eks update-kubeconfig --name setrass-ecms-aws-eks-cluster --region us-east-1')
//                            sh "./kubectl apply -f k8s.yml -n development"
//                        }
//                    }
//                } else {
//                    configFileProvider(
//                        [configFile(fileId: '4a6a1fe9-3181-4d06-8dd0-01c74acce756', targetLocation: 'prod.yml', variable: 'CLUSTER')]) 
//                        {
//                            sh "./kubectl --kubeconfig $CLUSTER apply -f k8s.yml -n ${env.ENTORNO}"
//                        }
//                    }
//                }
            }

        }
    }
}
