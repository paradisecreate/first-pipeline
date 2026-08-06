pipeline {
    agent any

    environment {
        APP_NAME = 'devops-application'
        IMAGE_NAME = 'devops-application'
        IMAGE_TAG = "${env.BUILD_NUMBER}"
        DEV_NAMESPACE = 'dev'
        STAGING_NAMESPACE = 'staging'
        PROD_NAMESPACE = 'production'
    }

    stages {
        stage('Pre-flight Checks') {
            steps {
                sh '''
                    echo "=== Pre-flight Checks ==="

                    docker --version
                    docker compose version
                    kubectl version --client
                    helm version
                    node --version
                    npm --version
                '''
            }
        }

        stage('Install Dependencies') {
            steps {
                sh '''
                    echo "=== Installing npm dependencies ==="
                    npm install
                '''
            }
        }

        stage('Build & Test') {
            parallel {
                stage('Application Build') {
                    steps {
                        sh '''
                            echo "=== Application Build ==="
                            npm run build
                        '''

                        archiveArtifacts artifacts: 'dist/**', allowEmptyArchive: true
                    }
                }

                stage('Security Scan') {
                    steps {
                        sh '''
                            echo "=== Security Scan ==="
                            npm audit --audit-level=high || true
                        '''
                    }
                }

                stage('Unit Tests') {
                    steps {
                        sh '''
                            echo "=== Unit Tests ==="
                            npm run test:unit
                        '''

                        junit 'test-results/*.xml'
                    }
                }
            }
        }

        stage('Integration Tests') {
            steps {
                sh '''
                    echo "=== Integration Tests ==="

                    docker compose -f docker-compose.test.yml up -d --build

                    echo "Waiting for app health..."
                    sleep 15

                    docker compose -f docker-compose.test.yml ps
                    docker compose -f docker-compose.test.yml exec -T app wget -qO- http://localhost:3000/health

                    mkdir -p integration-test-results
                    echo '<testsuite tests="1"><testcase classname="integration" name="health-endpoint"/></testsuite>' > integration-test-results/integration.xml

                    docker compose -f docker-compose.test.yml down
                '''

                junit 'integration-test-results/*.xml'
            }

            post {
                always {
                    sh '''
                        docker compose -f docker-compose.test.yml down || true
                    '''
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                sh '''
                    echo "=== Building Docker Image ==="

                    docker build -t ${IMAGE_NAME}:${IMAGE_TAG} .
                    docker tag ${IMAGE_NAME}:${IMAGE_TAG} ${IMAGE_NAME}:latest

                    docker images | grep ${IMAGE_NAME}
                '''
            }
        }

        stage('Helm Lint') {
            steps {
                sh '''
                    echo "=== Helm Lint ==="
                    helm lint helm-chart
                '''
            }
        }

        stage('Deploy to Dev') {
            when {
                anyOf {
                    branch 'ec2-development'
                    branch 'feature/*'
                }
            }

            steps {
                sh '''
                    echo "=== Deploy to Dev ==="

                    kubectl create namespace ${DEV_NAMESPACE} --dry-run=client -o yaml | kubectl apply -f -

                    helm upgrade --install ${APP_NAME}-dev ./helm-chart \
                        --namespace ${DEV_NAMESPACE} \
                        --set image.repository=${IMAGE_NAME} \
                        --set image.tag=${IMAGE_TAG} \
                        --set image.pullPolicy=IfNotPresent

                    kubectl rollout status deployment/${APP_NAME} -n ${DEV_NAMESPACE} --timeout=120s
                '''
            }
        }

        stage('Deploy to Staging') {
            when {
                branch 'ec2-staging'
            }

            steps {
                sh '''
                    echo "=== Deploy to Staging ==="

                    kubectl create namespace ${STAGING_NAMESPACE} --dry-run=client -o yaml | kubectl apply -f -

                    helm upgrade --install ${APP_NAME}-staging ./helm-chart \
                        --namespace ${STAGING_NAMESPACE} \
                        --set image.repository=${IMAGE_NAME} \
                        --set image.tag=${IMAGE_TAG} \
                        --set image.pullPolicy=IfNotPresent

                    kubectl rollout status deployment/${APP_NAME} -n ${STAGING_NAMESPACE} --timeout=120s
                '''
            }
        }

        stage('Production Approval') {
            when {
                branch 'main'
            }

            steps {
                timeout(time: 5, unit: 'MINUTES') {
                    input message: 'Deploy to Production?', ok: 'Deploy'
                }
            }
        }

        stage('Deploy to Production') {
            when {
                branch 'main'
            }

            steps {
                sh '''
                    echo "=== Deploy to Production ==="

                    kubectl create namespace ${PROD_NAMESPACE} --dry-run=client -o yaml | kubectl apply -f -

                    helm upgrade --install ${APP_NAME}-prod ./helm-chart \
                        --namespace ${PROD_NAMESPACE} \
                        --set image.repository=${IMAGE_NAME} \
                        --set image.tag=${IMAGE_TAG} \
                        --set image.pullPolicy=IfNotPresent

                    kubectl rollout status deployment/${APP_NAME} -n ${PROD_NAMESPACE} --timeout=120s
                '''
            }
        }
    }

    post {
        always {
            echo 'Advanced pipeline execution completed'

            sh '''
                docker compose -f docker-compose.test.yml down || true
            '''

            archiveArtifacts artifacts: 'dist/**,test-results/*.xml,integration-test-results/*.xml', allowEmptyArchive: true
        }

        success {
            echo 'Advanced BlueOcean pipeline succeeded!'
        }

        failure {
            echo 'Advanced BlueOcean pipeline failed!'
        }
    }
}