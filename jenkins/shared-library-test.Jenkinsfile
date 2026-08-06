@Library('devops-shared-library') _

pipeline {
    agent any

    stages {
        stage('Deploy Application') {
            steps {
                deployApp([
                    appName: 'web-app',
                    environment: 'staging',
                    version: '1.0.0'
                ])

                notifySlack("Deployment completed for build ${env.BUILD_NUMBER}")
            }
        }
    }
}