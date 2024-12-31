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
                unstash 'app'
                //sh 'sleep 15'
            }

        }
    }
}
