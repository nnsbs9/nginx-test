# Installing Harness Delegate in GKE

This guide will help you install the Harness Delegate in your existing GKE cluster.

## Prerequisites

1. **Harness Account**: You need a Harness account (https://app.harness.io)
2. **GKE Cluster**: Your cluster should be running (you already have `nginx-cluster`)
3. **kubectl**: Configured to access your GKE cluster

## Method 1: Using Kubernetes YAML (Recommended)

### Step 1: Get Delegate YAML from Harness UI

1. Log in to Harness: https://app.harness.io
2. Navigate to **Project Setup** → **Delegates**
3. Click **Create a Delegate**
4. Select **Kubernetes** as the platform
5. Choose **YAML** (not Helm)
6. Fill in the delegate details:
   - **Name**: e.g., `gke-delegate`
   - **Description**: Optional
   - **Tags**: Optional (useful for targeting specific delegates)
7. Click **Download YAML**

### Step 2: Apply the Delegate YAML

```bash
# Apply the downloaded YAML file
kubectl apply -f harness-delegate.yaml

# Or if you saved it with a different name
kubectl apply -f <downloaded-yaml-file>
```

### Step 3: Verify Installation

```bash
# Check if the delegate pod is running
kubectl get pods -n harness-delegate-ng

# Check delegate logs
kubectl logs -n harness-delegate-ng -l app=harness-delegate --tail=50

# Check delegate status in Harness UI
# Go to Project Setup → Delegates
# You should see your delegate with status "Connected" (green)
```

## Method 2: Using Helm

### Step 1: Install Helm (if not already installed)

```bash
# macOS
brew install helm

# Or download from: https://helm.sh/docs/intro/install/
```

### Step 2: Get Delegate Values from Harness UI

1. Log in to Harness: https://app.harness.io
2. Navigate to **Project Setup** → **Delegates**
3. Click **Create a Delegate**
4. Select **Kubernetes** as the platform
5. Choose **Helm Chart**
6. Download the `harness-delegate-values.yaml` file

### Step 3: Install Using Helm

```bash
# Add Harness Helm repository
helm repo add harness-delegate https://app.harness.io/storage/harness-download/delegate-helm-chart/
helm repo update

# Install the delegate
helm upgrade -i harness-delegate harness-delegate/harness-delegate-ng \
  --namespace harness-delegate-ng \
  --create-namespace \
  -f harness-delegate-values.yaml
```

### Step 4: Verify Installation

```bash
# Check if the delegate pod is running
kubectl get pods -n harness-delegate-ng

# Check Helm release
helm list -n harness-delegate-ng
```

## Troubleshooting

### Delegate Not Connecting

1. **Check pod status**:
   ```bash
   kubectl get pods -n harness-delegate-ng
   kubectl describe pod -n harness-delegate-ng <pod-name>
   ```

2. **Check logs**:
   ```bash
   kubectl logs -n harness-delegate-ng -l app=harness-delegate --tail=100
   ```

3. **Verify delegate token**: Make sure the delegate token in the YAML is correct and not expired

4. **Check network connectivity**: The delegate needs to reach `https://app.harness.io` (or your Harness manager endpoint)

5. **Check resource limits**: Ensure the cluster has enough resources:
   ```bash
   kubectl top nodes
   kubectl describe nodes
   ```

### Common Issues

- **ImagePullBackOff**: Check if the delegate image can be pulled (may need Docker Hub credentials)
- **CrashLoopBackOff**: Check logs for configuration errors
- **Pending**: Check if there are enough resources in the cluster

## Delegate Configuration

### Resource Requirements

The delegate typically needs:
- **CPU**: 0.5-2 cores
- **Memory**: 1-4 GB

You can adjust these in the YAML or values file.

### Using with Your Existing Cluster

Since you're using a minimal e2-micro cluster, you may need to:
1. Increase cluster size or use a larger node
2. Adjust delegate resource requests/limits
3. Consider using a separate namespace to isolate resources

## Next Steps

Once the delegate is connected:
1. **Verify in Harness UI**: Go to Project Setup → Delegates
2. **Test connectivity**: Run a simple pipeline to test the delegate
3. **Configure tags**: Use tags to target specific delegates for specific workloads

## Cleanup

To remove the delegate:

```bash
# If installed via YAML
kubectl delete -f harness-delegate.yaml

# If installed via Helm
helm uninstall harness-delegate -n harness-delegate-ng
kubectl delete namespace harness-delegate-ng
```

