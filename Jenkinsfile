pipeline {
    agent any

    environment {
        APP_NAME = 'petclinic'
        DOCKERFILE_PATH = 'Dockerfile'
        WAR_FILE = 'target/*.war'
        SONAR_PROJECT_KEY = 'petclinic'
        SONAR_PLUGIN_VERSION = 'org.sonarsource.scanner.maven:sonar-maven-plugin:4.0.0.4121'
        SCAN_TYPE = 'Full'
        AWS_REGION = 'us-east-1'
        ECR_REPO_URI = '863518452866.dkr.ecr.us-east-1.amazonaws.com/petclinic'
        RECIPIENTS = 'abhijithsaseendran753@gmail.com'
        TRIGGER_BY = currentBuild.getBuildCauses().join(', ')
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
        
        // Other stages as before...

        stage('Run OWASP ZAP Scan') {
            steps {
                script {
                    def scanCommand = ""
                    if (SCAN_TYPE == 'Baseline') {
                        scanCommand = 'zap-baseline.py -t https://google.com'
                    } else if (SCAN_TYPE == 'API') {
                        scanCommand = 'zap-api-scan.py -t https://google.com/openapi.json'
                    } else if (SCAN_TYPE == 'Full') {
                        scanCommand = 'zap-full-scan.py -t https://google.com'
                    }
                    sh "docker exec owasp ${scanCommand} -r report.html -I"
                }
            }
        }

        // More stages...
    }

    post {
        success {
            script {
                def buildStatus = currentBuild.currentResult
                def commitId = sh(script: 'git rev-parse --short HEAD', returnStdout: true).trim()
                def buildLink = "<a href='${BUILD_URL}'>${BUILD_URL}</a>"
                def triggerBy = TRIGGER_BY

                def attachments = []
                if (fileExists('hadolint_report.txt')) {
                    attachments.add([filePath: 'hadolint_report.txt', mimeType: 'text/plain'])
                }
                if (fileExists('report.html')) {
                    attachments.add([filePath: 'report.html', mimeType: 'text/html'])
                }

                emailext (
                    to: RECIPIENTS,
                    subject: "Build ${buildStatus} - Commit ID: ${commitId}",
                    body: """
                        <p>Build Status: ${buildStatus}</p>
                        <p>Commit ID: ${commitId}</p>
                        <p>Build Link: ${buildLink}</p>
                        <p>Triggered By: ${triggerBy}</p>
                    """,
                    attachLog: true,
                    attachmentsPattern: attachments.collect { it.filePath }.join(','),
                    mimeType: 'text/html'
                )
            }
        }
        failure {
            echo "Pipeline failed."
        }
        always {
            archiveArtifacts artifacts: 'hadolint_report.txt', allowEmptyArchive: true
            archiveArtifacts artifacts: '**/*.html', allowEmptyArchive: true
            sh 'docker image prune -f'
        }
    }
}
