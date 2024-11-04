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
                // Assuming Maven is used for Java project
                sh 'mvn clean package -DskipTests'
                archiveArtifacts artifacts: WAR_FILE, allowEmptyArchive: false
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

        stage('Run Docker Container') {
            steps {
                script {
                    // Run the Docker container
                    docker.run(DOCKER_IMAGE, '-d -p 8080:8080')
                }
            }
        }
    }

    post {
        success {
            echo 'Deployment successful!'
        }
        failure {
            echo 'Deployment failed.'
        }
        always {
            // Optional: Cleanup
            script {
                echo 'Cleaning up Docker containers...'
                sh 'docker container prune -f'
            }
        }
    }
}
