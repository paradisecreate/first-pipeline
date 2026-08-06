pipeline {
    agent any

    stages {
        stage('Collect EC2 Info') {
            steps {
                sh '''
                    echo "=== EC2 Instance Information ===" > ec2-info.txt
                    echo "Instance ID: $(curl -s http://169.254.169.254/latest/meta-data/instance-id)" >> ec2-info.txt
                    echo "Instance Type: $(curl -s http://169.254.169.254/latest/meta-data/instance-type)" >> ec2-info.txt
                    echo "Public IP: $(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)" >> ec2-info.txt
                    echo "Region: $(curl -s http://169.254.169.254/latest/meta-data/placement/region)" >> ec2-info.txt
                    echo "AZ: $(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone)" >> ec2-info.txt

                    cat ec2-info.txt
                '''

                archiveArtifacts artifacts: 'ec2-info.txt', allowEmptyArchive: false
            }
        }
    }

    post {
        always {
            echo 'EC2 info pipeline completed'
        }

        success {
            echo 'EC2 info collected successfully!'
        }

        failure {
            echo 'EC2 info collection failed!'
        }
    }
}