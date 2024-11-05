pipeline {
    agent any

    environment {
        APP_NAME = 'petclinic'  // Change this to your desired image name
        WAR_FILE = 'target/*.war' // Path to the WAR file
        DOCKER_IMAGE = "${env.APP_NAME}:latest"
    }

    stages {
        stage('Checkout') {
            steps {
                // Checkout your repository from the main branch
                git branch: 'main', url: 'https://github.com/abhijith3707/spring-framework-petclinic.git'
            }
        }

        stage('Build') { 
            steps {
                sh 'mvn -B -DskipTests clean package' 
            }
        }

        stage('OWASP Dependency-Check Vulnerabilities') {
            steps {
                dependencyCheck additionalArguments: ''' 
                    -o './'
                    -s './'
                    -f 'ALL' 
                    --prettyPrint''', odcInstallation: 'OWASP Dependency-Check Vulnerabilities'
                
                dependencyCheckPublisher pattern: 'dependency-check-report.xml'
            }
        }

        stage('Build WAR Package') {
            steps {
                echo 'Building the WAR package...'
                sh 'mvn clean package -DskipTests'
                archiveArtifacts artifacts: WAR_FILE, allowEmptyArchive: false
            }
        }

        stage('Lint Dockerfile') {
            steps {
                // Using Hadolint to lint the Dockerfile
                sh 'docker run --rm -i hadolint/hadolint < Dockerfile > hadolint_report.txt'
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    // Build the Docker image
                    docker.build(DOCKER_IMAGE) // Use DOCKER_IMAGE variable here
                }
            }
        }
    }

    post {
        success {
            echo 'Pipeline completed successfully!'
        }
        failure {
            echo 'Pipeline failed.'
        }
        always {
            archiveArtifacts artifacts: 'hadolint_report.txt', allowEmptyArchive: true
            // Optional: Clean up Docker containers if needed
            sh 'docker container prune -f'
        }
    }
}
