# Deploying Nginx to Google Cloud Platform

This guide will walk you through deploying your nginx application to Google Cloud Platform (GCP) using Google Kubernetes Engine (GKE).

## Prerequisites

1. **Google Cloud Account** - You have a new GCP account
2. **Google Cloud SDK (gcloud)** - Install from https://cloud.google.com/sdk/docs/install
3. **Docker** - Install from https://docs.docker.com/get-docker/
4. **kubectl** - Will be installed via gcloud

## Step 1: Install and Configure Google Cloud SDK

If you haven't already, install the Google Cloud SDK and authenticate:

```bash
# Install gcloud (if not already installed)
# macOS:
brew install --cask google-cloud-sdk

# Or download from: https://cloud.google.com/sdk/docs/install

# Authenticate with your Google account
gcloud auth login

# Set your project (replace PROJECT_ID with your actual project ID)
gcloud config set project PROJECT_ID

# Enable required APIs
gcloud services enable container.googleapis.com
```

## Step 2: Create a Minimal GKE Cluster

**Note:** Your Docker image `nnsbs9/nginx-test:latest` is already in Docker Hub, so no build/push is needed!

Create a minimal Kubernetes cluster for this experiment (using smallest resources to minimize cost):

```bash
# Set your preferred region/zone
export ZONE=us-central1-a  # Change to your preferred zone

# Create a minimal GKE cluster (single node, smallest machine, preemptible for lowest cost)
gcloud container clusters create nginx-cluster \
  --zone=$ZONE \
  --num-nodes=1 \
  --machine-type=e2-micro \
  --preemptible

# Get credentials for kubectl
gcloud container clusters get-credentials nginx-cluster --zone=$ZONE
```

**Note:** This uses minimal resources for cost savings:
- **Single node** (instead of 2+)
- **e2-micro** (smallest machine type)
- **Preemptible** (up to 80% cheaper, but can be terminated by GCP with 30s notice)

## Step 3: Deploy to GKE

Your `deployment.yaml` already references the Docker Hub image `nnsbs9/nginx-test:latest`, so no changes needed!

Deploy your application:

```bash
# Apply the Kubernetes manifests
kubectl apply -f k8s/

# Check deployment status
kubectl get pods -l app=nginx-test
kubectl get svc nginx-test

# View logs if needed
kubectl logs -l app=nginx-test
```

## Step 4: Expose the Service (Optional)

To make nginx accessible from the internet, you can either:

### Option A: Change Service to LoadBalancer

Edit `k8s/service.yaml` and change:
```yaml
spec:
  type: ClusterIP
```
to:
```yaml
spec:
  type: LoadBalancer
```

Then apply:
```bash
kubectl apply -f k8s/service.yaml
kubectl get svc nginx-test
# Wait for EXTERNAL-IP to be assigned
```

### Option B: Use Port Forwarding (for testing)

```bash
kubectl port-forward svc/nginx-test 8080:80
# Then visit http://localhost:8080
```

## Step 5: Clean Up (When Done)

To avoid ongoing charges, delete the cluster when you're done:

```bash
gcloud container clusters delete nginx-cluster --zone=$ZONE
```

## Troubleshooting

### Check cluster status
```bash
gcloud container clusters list
```

### View pod logs
```bash
kubectl logs -l app=nginx-test
```

### Describe pods for errors
```bash
kubectl describe pods -l app=nginx-test
```

### Check if pods can pull image from Docker Hub
```bash
kubectl describe pod -l app=nginx-test
# Look for ImagePullBackOff errors - Docker Hub should work without authentication for public images
```

## Cost Considerations

**This experiment uses minimal resources:**
- Single node cluster (reduces cost by ~50%)
- e2-micro machine type (smallest/cheapest)
- Preemptible nodes (up to 80% cheaper than regular nodes)
- Single replica deployment (1 pod instead of 2)

**Important:**
- **Delete the cluster when done** to avoid ongoing charges: `gcloud container clusters delete nginx-cluster --zone=$ZONE`
- Preemptible nodes can be terminated by GCP (with 30s notice) - fine for experiments
- Monitor costs in the GCP Console
- GKE has a minimum charge even when idle, so delete when not using

## Next Steps

- Set up CI/CD with Cloud Build
- Configure custom domains with Ingress
- Add SSL/TLS certificates
- Set up monitoring and logging
- Configure autoscaling

