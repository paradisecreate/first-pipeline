pipeline {
    agent any

    environment {
        SERVER_REGION = 'us-east-1'
        BUILD_ENV = 'development'
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
                echo 'Repository downloaded from Git'
            }
        }

        stage('Script Validation') {
            steps {
                sh '''
                    echo "=== Script Validation ==="

                    for script in *.sh; do
                        if [ -f "$script" ]; then
                            echo "Checking syntax: $script"
                            bash -n "$script"
                        fi
                    done
                '''
            }
        }

        stage('Test Scripts') {
            steps {
                sh '''
                    echo "=== Testing Scripts ==="
                    chmod +x *.sh

                    if [ -f "system-info.sh" ]; then
                        echo "Running system-info.sh"
                        ./system-info.sh
                    fi

                    if [ -f "health-check.sh" ]; then
                        echo "Running health-check.sh"
                        ./health-check.sh
                    fi
                '''
            }
        }

        stage('Deploy Scripts') {
            when {
                branch 'main'
            }

            steps {
                sh '''
                    echo "=== Deploying Scripts ==="

                    mkdir -p /var/lib/jenkins/deployed-scripts
                    cp *.sh /var/lib/jenkins/deployed-scripts/
                    chmod +x /var/lib/jenkins/deployed-scripts/*.sh

                    echo "Deployment completed"
                    ls -la /var/lib/jenkins/deployed-scripts/
                '''
            }
        }
    }

    post {
        always {
            echo 'Pipeline completed'
            archiveArtifacts artifacts: '*.sh', allowEmptyArchive: true
        }

        success {
            echo 'Pipeline succeeded!'
        }

        failure {
            echo 'Pipeline failed!'
        }
    }
}
