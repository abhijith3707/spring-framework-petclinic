pipeline {
    agent any

    environment {
        APP_NAME = 'petclinic'  // Desired image name
        DOCKERFILE_PATH = 'Dockerfile' // Path to your Dockerfile
        WAR_FILE = 'target/*.war' // Path to the WAR file
        TRIVY_REPORT = 'trivy_report.pdf' // PDF report filename
    }

    stages {
        stage('Checkout') {
            steps {
                // Checkout the code from the main branch
                git branch: 'main', url: 'https://github.com/abhijith3707/spring-framework-petclinic.git'
            }
        }

        stage('Check Disk Space') {
            steps {
                sh 'df -h'
            }
        }

        stage('Lint Dockerfile') {
            steps {
                // Use Hadolint to lint the Dockerfile and save output
                sh 'docker run --rm -i hadolint/hadolint < ${DOCKERFILE_PATH} > hadolint_report.txt'
            }
        }

        stage('Build WAR Package') {
            steps {
                echo 'Building the WAR package...'
                // Build WAR file using Maven
                sh 'mvn -B -DskipTests clean package'
                archiveArtifacts artifacts: WAR_FILE, allowEmptyArchive: false
            }
        }

        stage('Build Docker Image with Dynamic Tagging') {
            steps {
                script {
                    // Define dynamic tags using commit ID and build number
                    def commitId = sh(script: 'git rev-parse --short HEAD', returnStdout: true).trim()
                    def buildNumber = env.BUILD_NUMBER
                    def dockerTag = "${APP_NAME}:${commitId}-${buildNumber}"
                    
                    // Build the Docker image with the dynamic tag
                    docker.build(dockerTag, "-f ${DOCKERFILE_PATH} .")

                    // Save the dynamic tag as an environment variable for future steps if needed
                    env.DYNAMIC_TAG = dockerTag
                }
            }
        }

        stage('Docker Image Vulnerability Scanning (Trivy)') {
            steps {
                script {
                    // Pull the Trivy image
                    sh 'docker pull aquasec/trivy:latest'

                    // Run Trivy to scan the Docker image and output results as a PDF
                    def imageTag = env.DYNAMIC_TAG
                    sh """
                        docker run -u 0 --rm -v $PWD:/tmp/.cache/ aquasec/trivy image --format template --template "@contrib/html.tpl" -o trivy_result.html 3edc2ce423c8/python:3.10_pip_aws
                    """
                }
            }
        }
    }

    post {
        success {
            echo "Pipeline completed successfully!"
        }
        failure {
            echo "Pipeline failed due to high/critical vulnerabilities."
        }
        always {
            // Archive the Hadolint report and Trivy PDF report
            archiveArtifacts artifacts: 'hadolint_report.txt', allowEmptyArchive: true
            archiveArtifacts artifacts: TRIVY_REPORT, allowEmptyArchive: true
            // Clean up dangling images
            sh 'docker image prune -f'
        }
    }
}
