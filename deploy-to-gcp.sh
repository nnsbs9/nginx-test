#!/bin/bash

# Deploy Nginx to Google Cloud Platform
# Usage: ./deploy-to-gcp.sh [PROJECT_ID] [ZONE]

set -e

PROJECT_ID=${1:-$(gcloud config get-value project 2>/dev/null)}
ZONE=${2:-us-central1-a}
CLUSTER_NAME="nginx-cluster"

if [ -z "$PROJECT_ID" ]; then
    echo "Error: PROJECT_ID is required"
    echo "Usage: $0 [PROJECT_ID] [ZONE]"
    echo "Or set it with: gcloud config set project PROJECT_ID"
    exit 1
fi

echo "Deploying to GCP (minimal resources for experiment)..."
echo "Project ID: $PROJECT_ID"
echo "Zone: $ZONE"
echo "Configuration: 1 node, e2-micro, preemptible (lowest cost)"
echo ""

# Step 1: Enable required APIs
echo "Enabling required APIs..."
gcloud services enable container.googleapis.com --project=$PROJECT_ID

# Step 2: Check if cluster exists, create if not
echo "Checking for existing cluster..."
if ! gcloud container clusters describe $CLUSTER_NAME --zone=$ZONE --project=$PROJECT_ID &>/dev/null; then
    echo "Creating minimal GKE cluster for experiment (this may take a few minutes)..."
    gcloud container clusters create $CLUSTER_NAME \
        --zone=$ZONE \
        --num-nodes=1 \
        --machine-type=e2-micro \
        --preemptible \
        --project=$PROJECT_ID
else
    echo "Cluster already exists, skipping creation."
fi

# Step 3: Get cluster credentials
echo "Getting cluster credentials..."
gcloud container clusters get-credentials $CLUSTER_NAME --zone=$ZONE --project=$PROJECT_ID

# Step 4: Deploy to Kubernetes (using existing Docker Hub image: nnsbs9/nginx-test:latest)
echo "Deploying to Kubernetes..."
kubectl apply -f k8s/

# Step 5: Wait for deployment
echo "Waiting for deployment to be ready..."
kubectl wait --for=condition=available --timeout=300s deployment/nginx-test

# Step 6: Show status
echo ""
echo "Deployment complete! Status:"
kubectl get pods -l app=nginx-test
kubectl get svc nginx-test

echo ""
echo "To access nginx:"
echo "  kubectl port-forward svc/nginx-test 8080:80"
echo "  Then visit: http://localhost:8080"
echo ""
echo "To expose publicly, edit k8s/service.yaml and change type to LoadBalancer"
echo "  kubectl apply -f k8s/service.yaml"
echo "  kubectl get svc nginx-test  # Wait for EXTERNAL-IP"

