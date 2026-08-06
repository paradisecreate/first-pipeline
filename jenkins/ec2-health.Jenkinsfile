pipeline {
    agent any

    triggers {
        cron('H/15 * * * *')
    }

    stages {
        stage('Health Check') {
            steps {
                sh '''
                    echo "=== EC2 Health Monitoring ==="

                    cd scripts
                    chmod +x health-check.sh
                    ./health-check.sh > ../health-report.txt

                    cd ..
                    cat health-report.txt

                    if grep -q "CRITICAL" health-report.txt; then
                        echo "CRITICAL issues found!"
                        exit 1
                    fi
                '''

                archiveArtifacts artifacts: 'health-report.txt', allowEmptyArchive: false
            }
        }
    }

    post {
        always {
            echo 'EC2 health monitoring pipeline completed'
        }

        success {
            echo 'EC2 health check passed!'
        }

        failure {
            echo 'EC2 health check failed!'
        }
    }
}