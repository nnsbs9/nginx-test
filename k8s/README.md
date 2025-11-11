# Kubernetes Deployment for Nginx Test

Simple Kubernetes manifests for running nginx-test.

## Files

- `deployment.yaml` - Deployment with 2 replicas of nginx-test using image `nnsbs9/nginx-test`
- `service.yaml` - ClusterIP service exposing nginx-test on ports 80 and 443

## Usage

### Deploy

```bash
kubectl apply -f k8s/
```

### Check status

```bash
kubectl get pods -l app=nginx-test
kubectl get svc nginx-test
```

### Access nginx-test

```bash
# Port forward to access locally
kubectl port-forward svc/nginx-test 8080:80

# Then visit http://localhost:8080
```

### Delete

```bash
kubectl delete -f k8s/
```

## Customization

- To change the number of replicas, edit `deployment.yaml` and modify `spec.replicas`
- To expose nginx-test externally, change `service.yaml` `spec.type` from `ClusterIP` to `LoadBalancer` or `NodePort`
- The deployment uses the private image `nnsbs9/nginx-test:latest` - update the `image` field in `deployment.yaml` if you need a different tag

