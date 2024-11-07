pipeline {
    agent any

    environment {
        APP_NAME = 'petclinic'  // Desired image name
        DOCKERFILE_PATH = 'Dockerfile' // Path to your Dockerfile
        WAR_FILE = 'target/*.war' // Path to the WAR file
        SONAR_PROJECT_KEY = 'petclinic' // SonarQube project key
        SONAR_PLUGIN_VERSION = 'org.sonarsource.scanner.maven:sonar-maven-plugin:4.0.0.4121' // Explicit SonarQube Maven plugin version
        SCAN_TYPE = 'Full'
    }

    parameters {
        choice(name: 'SCAN_TYPE', choices: ['Baseline', 'API', 'Full'], description: 'Select ZAP scan type')
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

        stage('SonarQube analysis') {
            steps {
                script {
                    withSonarQubeEnv('server-sonar') {
                        sh '''
                        /opt/sonar-scanner/bin/sonar-scanner \
                        -Dsonar.projectKey=demo-project \
                        -Dsonar.sourceEncoding=UTF-8 \
                        -Dsonar.language=java \
                        -Dsonar.sources=. \
                        -Dsonar.tests=. \
                        -Dsonar.java.binaries=. \
                        -Dsonar.java.test.binaries=. \
                        -Dsonar.test.inclusions=/Test/ \
                        '''
                    }
                }
            }
        }

        stage("SonarQube Quality Gate Check") {
            steps {
                script {
                    def qualityGate = waitForQualityGate()
                    if (qualityGate.status != 'OK') {
                        echo "${qualityGate.status}"
                        error "Quality Gate failed: ${qualityGateStatus}"
                    } else {
                        echo "${qualityGate.status}"
                        echo "SonarQube Quality Gates Passed"
                    }
                }
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

    stage('Run OWASP ZAP Scan') {
    steps {
        script {
            def scanCommand = ""
            
            // Determine the ZAP scan command based on the selected scan type
            if (SCAN_TYPE == 'Baseline') {
                scanCommand = 'zap-baseline.py -t http://google.com'
            } else if (SCAN_TYPE == 'API') {
                scanCommand = 'zap-api-scan.py -t http://google.com/openapi.json'
            } else if (SCAN_TYPE == 'Full') {
                scanCommand = 'zap-full-scan.py -t http://google.com'
            }

            // Pull the latest image

            // Start OWASP ZAP in daemon mode
            sh " docker exec owasp zap-baseline.py -t https://medium.com/ -r report.html -I"

            // Run the selected ZAP scan command
            // sh """
            // docker exec zap-daemon $scanCommand
            // """

            // Stop and remove the ZAP container after the scan
            //sh "docker stop zap-daemon && docker rm zap-daemon"
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

        // Trivy scan stage is commented out
        /*
        stage('trivy-scan') {
            steps {
                script {
                    // scan the image
                    sh 'docker run   --rm   -v "$(realpath .):/opt/src"   -v /run/docker.sock:/var/run/docker.sock   -v /tmp/trivy-cache:/cache   -e "TRIVY_DB_REPOSITORY=public.ecr.aws/aquasecurity/trivy-db"   -e "TRIVY_JAVA_DB_REPOSITORY=public.ecr.aws/aquasecurity/trivy-java-db"   -w /opt/src   aquasec/trivy:0.56.2 --cache-dir /cache image --quiet "${APP_NAME}:${commitId}-${buildNumber}"'
                }
            }
        }
        */

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
            archiveArtifacts artifacts: '**/*.html', allowEmptyArchive: true  // Archive ZAP scan reports
            sh 'docker image prune -f'
        }
    }
}
