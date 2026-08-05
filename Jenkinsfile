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
                    def currentBranch = env.BRANCH_NAME ?: 'main'

                    if (currentBranch == 'main') {
                        env.BRANCH_TYPE = 'production'
                    } else if (currentBranch == 'ec2-staging') {
                        env.BRANCH_TYPE = 'staging'
                    } else if (currentBranch == 'ec2-development') {
                        env.BRANCH_TYPE = 'development'
                    } else if (currentBranch.startsWith('feature/')) {
                        env.BRANCH_TYPE = 'feature'
                    } else {
                        env.BRANCH_TYPE = 'other'
                    }

                    env.CURRENT_BRANCH = currentBranch
                }

                sh '''
                    echo "=== Pipeline Information ==="
                    echo "Branch: $CURRENT_BRANCH"
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

                    mkdir -p /var/lib/jenkins/deployed-scripts/dev
                    cp *.sh /var/lib/jenkins/deployed-scripts/dev/
                    chmod +x /var/lib/jenkins/deployed-scripts/dev/*.sh

                    echo "Development deployment completed"
                    ls -la /var/lib/jenkins/deployed-scripts/dev/
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

                    mkdir -p /var/lib/jenkins/deployed-scripts/staging
                    cp *.sh /var/lib/jenkins/deployed-scripts/staging/
                    chmod +x /var/lib/jenkins/deployed-scripts/staging/*.sh

                    echo "Staging deployment completed"
                    ls -la /var/lib/jenkins/deployed-scripts/staging/
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

                    mkdir -p /var/lib/jenkins/deployed-scripts/prod
                    cp *.sh /var/lib/jenkins/deployed-scripts/prod/
                    chmod +x /var/lib/jenkins/deployed-scripts/prod/*.sh

                    echo "Production deployment completed"
                    ls -la /var/lib/jenkins/deployed-scripts/prod/
                '''
            }
        }
    }

    post {
        always {
            echo "Pipeline completed for branch: ${env.CURRENT_BRANCH}"
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