pipeline {
    agent any

    parameters {
        choice(
            name: 'DEPLOY_TARGET',
            choices: ['current-instance', 'all-instances'],
            description: 'Deployment Target'
        )

        booleanParam(
            name: 'RUN_HEALTH_CHECK',
            defaultValue: true,
            description: 'Run Health Check'
        )
    }

    environment {
        SERVER_REGION = 'us-east-1'
        BUILD_ENV = 'development'
    }

    stages {
        stage('Prepare') {
            steps {
                script {
                    if (env.BRANCH_NAME == 'main') {
                        env.BRANCH_TYPE = 'production'
                    } else if (env.BRANCH_NAME == 'ec2-staging') {
                        env.BRANCH_TYPE = 'staging'
                    } else if (env.BRANCH_NAME == 'ec2-development') {
                        env.BRANCH_TYPE = 'development'
                    } else if (env.BRANCH_NAME.startsWith('feature/')) {
                        env.BRANCH_TYPE = 'feature'
                    } else {
                        env.BRANCH_TYPE = 'other'
                    }
                }

                sh '''
                    echo "=== Pipeline Information ==="
                    echo "Branch: $BRANCH_NAME"
                    echo "Branch Type: $BRANCH_TYPE"
                    echo "Deploy Target: $DEPLOY_TARGET"
                    echo "Run Health Check: $RUN_HEALTH_CHECK"
                    echo "Workspace: $WORKSPACE"
                '''
            }
        }

        stage('Validate Scripts') {
            steps {
                sh '''
                    cd scripts
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
            when {
                expression { params.RUN_HEALTH_CHECK == true }
            }

            parallel {
                stage('Syntax Tests') {
                    steps {
                        sh '''
                            cd scripts
                            echo "Running syntax tests..."

                            for script in *.sh; do
                                if [ -f "$script" ]; then
                                    bash -n "$script"
                                    echo "$script syntax OK"
                                fi
                            done
                        '''
                    }
                }

                stage('Functionality Tests') {
                    steps {
                        sh '''
                            cd scripts
                            echo "Running functionality tests..."
                            chmod +x *.sh

                            if [ -f "system-info.sh" ]; then
                                ./system-info.sh
                            fi

                            if [ -f "health-check.sh" ]; then
                                ./health-check.sh
                            fi
                        '''
                    }
                }
            }
        }

        stage('Deploy to Development') {
            when {
                anyOf {
                    branch 'ec2-development'
                    branch 'feature/*'
                }
            }

            steps {
                sh '''
                    cd scripts
                    echo "=== Deploying to Development ==="

                    sudo mkdir -p /opt/ec2-scripts/dev
                    sudo cp *.sh /opt/ec2-scripts/dev/
                    sudo chmod +x /opt/ec2-scripts/dev/*.sh

                    echo "Development deployment completed"
                    ls -la /opt/ec2-scripts/dev/
                '''
            }
        }

        stage('Deploy to Staging') {
            when {
                branch 'ec2-staging'
            }

            steps {
                sh '''
                    cd scripts
                    echo "=== Deploying to Staging ==="

                    sudo mkdir -p /opt/ec2-scripts/staging
                    sudo cp *.sh /opt/ec2-scripts/staging/
                    sudo chmod +x /opt/ec2-scripts/staging/*.sh

                    echo "Staging deployment completed"
                    ls -la /opt/ec2-scripts/staging/
                '''
            }
        }

        stage('Deploy to Production') {
            when {
                branch 'main'
            }

            steps {
                sh '''
                    cd scripts
                    echo "=== Deploying to Production ==="

                    sudo mkdir -p /opt/ec2-scripts/prod
                    sudo cp *.sh /opt/ec2-scripts/prod/
                    sudo chmod +x /opt/ec2-scripts/prod/*.sh

                    echo "Production deployment completed"
                    ls -la /opt/ec2-scripts/prod/
                '''
            }
        }
    }

    post {
        always {
            echo "Pipeline completed for branch: ${env.BRANCH_NAME}"
            archiveArtifacts artifacts: 'scripts/*.sh', allowEmptyArchive: true
        }

        success {
            echo "Pipeline succeeded!"
        }

        failure {
            echo "Pipeline failed!"
        }
    }
}