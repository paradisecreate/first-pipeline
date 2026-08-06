def call(Map config) {
    echo "Deploying ${config.appName} to ${config.environment}"

    sh """
        echo "=== Shared Library Deployment ==="
        echo "Application: ${config.appName}"
        echo "Environment: ${config.environment}"
        echo "Version: ${config.version}"
        echo "Deployment completed successfully"
    """
}