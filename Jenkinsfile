pipeline {
    agent any

    environment {
        APP_NAME = 'petclinic'  // Desired image name
        DOCKERFILE_PATH = 'Dockerfile' // Path to your Dockerfile
        WAR_FILE = 'target/*.war' // Path to the WAR file
        SONAR_PROJECT_KEY = 'petclinic' // SonarQube project key
        SONAR_PLUGIN_VERSION = 'org.sonarsource.scanner.maven:sonar-maven-plugin:4.0.0.4121' // Explicit SonarQube Maven plugin version
    }

    stages {
        stage('Checkout') {
            steps {
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
                sh "docker run --rm -i hadolint/hadolint < ${DOCKERFILE_PATH} > hadolint_report.txt"
            }
        }

        stage('Build WAR Package') {
            steps {
                echo 'Building the WAR package...'
                sh 'mvn -B -DskipTests clean package'
                archiveArtifacts artifacts: WAR_FILE, allowEmptyArchive: false
            }
        }

        stage('SonarQube Analysis') {
            steps {
                script {
                    withSonarQubeEnv('server-sonar') { // Ensure this matches your configured server name in Jenkins
                sh "mvn -X ${SONAR_PLUGIN_VERSION}:sonar -Dsonar.projectKey=${SONAR_PROJECT_KEY}"
                    }
                }
            }
        }

        stage('Quality Gate Check') {
            steps {
                timeout(time: 5, unit: 'MINUTES') {
                    script {
                        def qualityGate = waitForQualityGate()
                        if (qualityGate.status != 'OK') {
                            error "Pipeline aborted due to quality gate failure: ${qualityGate.status}"
                        }
                    }
                }
            }
        }

        stage('Build Docker Image with Dynamic Tagging') {
            steps {
                script {
                    def commitId = sh(script: 'git rev-parse --short HEAD', returnStdout: true).trim()
                    def buildNumber = env.BUILD_NUMBER
                    def dockerTag = "${APP_NAME}:${commitId}-${buildNumber}"
                    
                    docker.build(dockerTag, "-f ${DOCKERFILE_PATH} .")
                    env.DYNAMIC_TAG = dockerTag
                }
            }
        }
    }

    post {
        success {
            echo "Pipeline completed successfully!"
        }
        failure {
            echo "Pipeline failed due to high/critical vulnerabilities or quality gate failure."
        }
        always {
            archiveArtifacts artifacts: 'hadolint_report.txt', allowEmptyArchive: true
            sh 'docker image prune -f'
        }
    }
}
