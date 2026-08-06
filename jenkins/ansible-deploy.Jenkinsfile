pipeline {
    agent any

    environment {
        APP_ENVIRONMENT = 'staging'
    }

    stages {
        stage('Check Ansible') {
            steps {
                sh '''
                    ansible --version
                    ansible-playbook --version
                '''
            }
        }

        stage('Deploy with Ansible') {
            steps {
                sh '''
                    ansible-playbook \
                        -i ansible/inventory/local.ini \
                        ansible/playbooks/deploy-app.yml \
                        --extra-vars "app_environment=${APP_ENVIRONMENT} app_version=${BUILD_NUMBER}"
                '''
            }
        }

        stage('Verify Deployment') {
            steps {
                sh '''
                    echo "=== Deployment directory ==="
                    ls -la /var/lib/jenkins/ansible-deployments/devops-application

                    echo "=== Deployment metadata ==="
                    cat /var/lib/jenkins/ansible-deployments/devops-application/deployment-info.txt

                    echo "=== Deployed scripts ==="
                    ls -la /var/lib/jenkins/ansible-deployments/devops-application/scripts
                '''
            }
        }
    }

    post {
        always {
            echo 'Ansible pipeline completed'
        }

        success {
            echo 'Ansible deployment succeeded!'
        }

        failure {
            echo 'Ansible deployment failed!'
        }
    }
}