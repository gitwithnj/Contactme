# Chaos Mesh Installation Guide

## Installation Summary

Chaos Mesh has been successfully installed on your Kubernetes cluster using Helm charts.

### Installation Details

- **Namespace**: `chaos-mesh`
- **Version**: 2.8.1
- **Installation Method**: Helm Chart
- **Runtime**: containerd
- **Socket Path**: `/run/containerd/containerd.sock`

## Components

Chaos Mesh consists of the following components:

1. **chaos-controller-manager**: Main controller that manages chaos experiments (3 replicas)
2. **chaos-daemon**: Daemon that runs on each node to inject chaos (DaemonSet)
3. **chaos-dashboard**: Web UI for managing chaos experiments
4. **chaos-dns-server**: DNS server for network chaos experiments

## Accessing Chaos Dashboard

### Option 1: Port Forward (Recommended)

```bash
kubectl port-forward -n chaos-mesh svc/chaos-dashboard 2333:2333
```

Then open: http://localhost:2333

### Option 2: Minikube Service

```bash
minikube service -n chaos-mesh chaos-dashboard
```

## Verifying Installation

### Check Pod Status

```bash
kubectl get pods -n chaos-mesh
```

All pods should be in `Running` state with `READY 1/1`.

### Check Services

```bash
kubectl get svc -n chaos-mesh
```

### Check Deployments

```bash
kubectl get deployments -n chaos-mesh
```

## Common Commands

### View Chaos Experiments

```bash
kubectl get chaos -A
```

### View All Chaos Mesh Resources

```bash
kubectl api-resources | grep chaos
```

### Check Logs

```bash
# Controller Manager logs
kubectl logs -n chaos-mesh -l app.kubernetes.io/component=controller-manager

# Dashboard logs
kubectl logs -n chaos-mesh -l app.kubernetes.io/component=chaos-dashboard

# Daemon logs
kubectl logs -n chaos-mesh -l app.kubernetes.io/component=chaos-daemon
```

## Troubleshooting

### If Pods Fail to Start

1. Check pod status:
   ```bash
   kubectl get pods -n chaos-mesh
   kubectl describe pod <pod-name> -n chaos-mesh
   ```

2. Check logs:
   ```bash
   kubectl logs <pod-name> -n chaos-mesh
   ```

3. Verify images are loaded:
   ```bash
   minikube image ls | grep chaos-mesh
   ```

### If Images Fail to Pull

If you encounter image pull errors, use the provided script:

```bash
./pull-chaos-mesh-images.sh
```

This script will:
- Pull images using Podman
- Load them into Minikube
- Update Helm values to use `imagePullPolicy: Never`

Then restart the deployments:

```bash
kubectl rollout restart deployment -n chaos-mesh
```

## Example Chaos Experiments

### Pod Failure Experiment

```yaml
apiVersion: chaos-mesh.org/v1alpha1
kind: PodChaos
metadata:
  name: pod-kill-example
  namespace: chaos-mesh
spec:
  action: pod-kill
  mode: one
  selector:
    namespaces:
      - default
    labelSelectors:
      app: resume-app
  scheduler:
    cron: "@every 2m"
```

### Network Chaos Experiment

```yaml
apiVersion: chaos-mesh.org/v1alpha1
kind: NetworkChaos
metadata:
  name: network-delay-example
  namespace: chaos-mesh
spec:
  action: delay
  mode: one
  selector:
    namespaces:
      - dockerimagesloaded
    labelSelectors:
      app: resume-app
  delay:
    latency: "10ms"
    correlation: "100"
    jitter: "0ms"
  duration: "30s"
```

## Uninstallation

To uninstall Chaos Mesh:

```bash
helm uninstall chaos-mesh -n chaos-mesh
kubectl delete namespace chaos-mesh
```

## Additional Resources

- [Chaos Mesh Documentation](https://chaos-mesh.org/docs/)
- [Chaos Mesh GitHub](https://github.com/chaos-mesh/chaos-mesh)
- [Chaos Experiments Examples](https://chaos-mesh.org/docs/simulate-pod-chaos-on-kubernetes/)
