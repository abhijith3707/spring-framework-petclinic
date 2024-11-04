pipeline {
    agent any

    stages {
        stage('Checkout') {
            steps {
                // Checkout your repository (update the URL to your repo)
                git 'https://github.com/abhijith3707/spring-framework-petclinic.git'
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
                archiveArtifacts artifacts: 'target/*.war', allowEmptyArchive: false
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    def appName = 'petclinic'  // Change this to your desired image name
                    // Build the Docker image
                    docker.build(appName) // Use appName variable here
                }
            }
        }

        stage('Run Docker Container') {
            steps {
                script {
                    // Run the Docker container
                    docker.run('petclinic', '-d -p 8080:8080')
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
    }
}
