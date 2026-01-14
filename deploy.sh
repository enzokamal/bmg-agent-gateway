#!/bin/bash

# Deployment script for BMG Agent Gateway Umbrella Chart
# Following the umbrella.yaml + environment files approach

set -e

# Function to display usage
usage() {
    echo "Usage: $0 <environment> [options]"
    echo ""
    echo "Environments:"
    echo "  develop    - Deploy to development environment"
    echo "  pre-prod   - Deploy to pre-production environment"
    echo "  prod       - Deploy to production environment"
    echo ""
    echo "Options:"
    echo "  --dry-run  - Show what would be deployed without actually deploying"
    echo "  --help      - Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 develop"
    echo "  $0 pre-prod --dry-run"
    echo "  $0 prod"
}

# Check if environment is provided
if [ $# -eq 0 ]; then
    echo "Error: Environment not specified"
    usage
    exit 1
fi

ENVIRONMENT=$1
shift

# Parse additional arguments
DRY_RUN=false
while [[ $# -gt 0 ]]; do
    case $1 in
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        --help)
            usage
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            usage
            exit 1
            ;;
    esac
done

# Validate environment and extract namespace from values file
case $ENVIRONMENT in
    develop)
        VALUES_FILE="develop.yaml"
        RELEASE_NAME="bmg-develop"
        # Extract namespace from develop.yaml
        NAMESPACE=$(grep '^namespace:' develop.yaml | head -1 | sed 's/namespace: "\(.*\)"/\1/' | sed 's/namespace: \(.*\)/\1/' | tr -d ' ')
        ;;
    pre-prod)
        VALUES_FILE="pre-prod.yaml"
        RELEASE_NAME="bmg-pre-prod"
        # Extract namespace from pre-prod.yaml
        NAMESPACE=$(grep '^namespace:' pre-prod.yaml | head -1 | sed 's/namespace: "\(.*\)"/\1/' | sed 's/namespace: \(.*\)/\1/' | tr -d ' ')
        ;;
    prod)
        VALUES_FILE="prod.yaml"
        RELEASE_NAME="bmg-prod"
        # Extract namespace from prod.yaml
        NAMESPACE=$(grep '^namespace:' prod.yaml | head -1 | sed 's/namespace: "\(.*\)"/\1/' | sed 's/namespace: \(.*\)/\1/' | tr -d ' ')
        ;;
    *)
        echo "Error: Invalid environment '$ENVIRONMENT'"
        usage
        exit 1
        ;;
esac

# Default to environment-specific namespace if not found in file
if [ -z "$NAMESPACE" ]; then
    case $ENVIRONMENT in
        develop)
            NAMESPACE="bmg-develop"
            ;;
        pre-prod)
            NAMESPACE="bmg-pre-prod"
            ;;
        prod)
            NAMESPACE="bmg-prod"
            ;;
    esac
fi

echo "🚀 Deploying BMG Agent Gateway to $ENVIRONMENT environment"
echo "📁 Values file: $VALUES_FILE"
echo "🗂️  Namespace: $NAMESPACE"
echo "🏷️  Release: $RELEASE_NAME"

# Build helm command
HELM_CMD="helm upgrade --install $RELEASE_NAME . \
    -f umbrella.yaml \
    -f $VALUES_FILE \
    --namespace $NAMESPACE \
    --create-namespace \
    --wait \
    --timeout 900s"

if [ "$DRY_RUN" = true ]; then
    echo "🔍 Dry run mode enabled"
    HELM_CMD="$HELM_CMD --dry-run"
fi

# Execute deployment
echo "⚡ Executing: $HELM_CMD"
eval $HELM_CMD

if [ $? -eq 0 ]; then
    if [ "$DRY_RUN" = true ]; then
        echo "✅ Dry run completed successfully"
    else
        echo "✅ Deployment to $ENVIRONMENT completed successfully"
        echo ""
        echo "🔍 Checking deployment status..."
        kubectl get pods -n $NAMESPACE
        echo ""
        echo "🌐 Gateway URL: http://$(kubectl get svc -n $NAMESPACE agentgateway-proxy -o jsonpath='{.status.loadBalancer.ingress[0].ip}'):8080"
        echo "🖥️  UI URL: http://$(kubectl get svc -n $NAMESPACE agentgateway-proxy -o jsonpath='{.status.loadBalancer.ingress[0].ip}'):8080/ui"
    fi
else
    echo "❌ Deployment failed"
    exit 1
fi