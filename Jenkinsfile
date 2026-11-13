pipeline {
    agent any

    environment {
        DOCKER_IMAGE = "kp6969/healthcare-ehr-app"
    }

    stages {
        stage('1. Checkout Healthcare Source') {
            steps {
                git branch: 'main', url: 'https://github.com/kritak0808/k8s-healthcare-devsecops.git'
            }
        }

        stage('2. IaC & Repo Security Scan (Trivy Config)') {
            steps {
                sh """
                docker run --rm -v "\${WORKSPACE}:/project" aquasec/trivy:latest config /project
                """
            }
        }

        stage('3. Build Hardened EHR Image') {
            steps {
                script {
                    docker.build("${DOCKER_IMAGE}:${BUILD_NUMBER}")
                }
            }
        }

        stage('4. Container Image CVE Scan (Trivy)') {
            steps {
                sh """
                docker run --rm -v /var/run/docker.sock:/var/run/docker.sock aquasec/trivy:latest image --severity HIGH,CRITICAL --exit-code 0 ${DOCKER_IMAGE}:${BUILD_NUMBER}
                """
            }
        }

        stage('5. Push Verified Image to Registry') {
            steps {
                script {
                    docker.withRegistry('https://index.docker.io/v1/', 'dockerhub-creds') {
                        def img = docker.image("${DOCKER_IMAGE}:${BUILD_NUMBER}")
                        img.push()
                        img.push('latest')
                    }
                }
            }
        }

        stage('6. Deploy to Healthcare K8s Cluster') {
            steps {
                withKubeConfig([credentialsId: 'kubeconfig-id']) {
                    sh 'kubectl --insecure-skip-tls-verify=true apply -f deployment.yaml'
                    sh "kubectl --insecure-skip-tls-verify=true set image deployment/healthcare-ehr-deployment healthcare-ehr=${DOCKER_IMAGE}:${BUILD_NUMBER}"
                    sh 'kubectl --insecure-skip-tls-verify=true rollout status deployment/healthcare-ehr-deployment'
                }
            }
        }
    }
}
