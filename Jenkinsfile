pipeline {
    agent any

    stages {
        stage('Unit Test') {
            steps {
                echo 'Running Maven Unit Tests'
                sh 'mvn test'
            }
        }
    }
}
