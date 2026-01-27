# Chaos Engineering Workflows

This directory contains pre-configured chaos engineering experiments for Chaos Mesh.

## Available Workflows

### Pod Chaos Experiments

1. **pod-kill-workflow.yaml** - Kills one pod at a time every 5 minutes
   - Action: Pod kill
   - Target: resume-app pods
   - Schedule: Every 5 minutes

2. **pod-failure-workflow.yaml** - Simulates pod failures
   - Action: Pod failure
   - Target: resume-app pods
   - Schedule: Every 20 minutes
   - Duration: 2 minutes

### Network Chaos Experiments

3. **network-delay-workflow.yaml** - Introduces network latency
   - Action: Network delay (100ms)
   - Target: resume-app pods
   - Schedule: Every 10 minutes
   - Duration: 30 seconds

4. **network-partition-workflow.yaml** - Partitions network between pods
   - Action: Network partition
   - Target: resume-app pods
   - Schedule: Every 15 minutes
   - Duration: 1 minute

5. **network-loss-workflow.yaml** - Introduces packet loss
   - Action: Packet loss (10%)
   - Target: resume-app pods
   - Schedule: Every 12 minutes
   - Duration: 30 seconds

6. **network-bandwidth-workflow.yaml** - Limits network bandwidth
   - Action: Bandwidth limit (1mbps)
   - Target: resume-app pods
   - Schedule: Every 18 minutes
   - Duration: 2 minutes

### Stress Chaos Experiments

7. **cpu-stress-workflow.yaml** - Applies CPU stress
   - Action: CPU stress (80% load, 2 workers)
   - Target: resume-app pods
   - Schedule: Every 30 minutes
   - Duration: 1 minute

8. **memory-stress-workflow.yaml** - Applies memory stress
   - Action: Memory stress (256Mi)
   - Target: resume-app pods
   - Schedule: Every 25 minutes
   - Duration: 1 minute

9. **io-stress-workflow.yaml** - Applies I/O stress
   - Action: I/O stress (128Mi)
   - Target: resume-app pods
   - Schedule: Every 35 minutes
   - Duration: 45 seconds

## Usage

### Import All Workflows

```bash
./import-chaos-workflows.sh
```

### Import Individual Workflow

```bash
kubectl apply -f chaos-workflows/<workflow-name>.yaml
```

### View Active Chaos Experiments

```bash
# View all chaos experiments
kubectl get chaos -A

# View specific types
kubectl get podchaos -n dockerimagesloaded
kubectl get networkchaos -n dockerimagesloaded
kubectl get stresschaos -n dockerimagesloaded
```

### Delete a Chaos Experiment

```bash
kubectl delete podchaos resume-app-pod-kill -n dockerimagesloaded
kubectl delete networkchaos resume-app-network-delay -n dockerimagesloaded
kubectl delete stresschaos resume-app-cpu-stress -n dockerimagesloaded
```

### Pause/Resume Chaos Experiments

```bash
# Pause
kubectl patch podchaos resume-app-pod-kill -n dockerimagesloaded -p '{"spec":{"duration":"0s"}}'

# Resume (restore original duration)
kubectl patch podchaos resume-app-pod-kill -n dockerimagesloaded -p '{"spec":{"duration":"10s"}}'
```

## Customization

You can customize these workflows by:

1. **Changing the target**: Modify the `selector.labelSelectors` to target different applications
2. **Adjusting schedules**: Change the `scheduler.cron` field
3. **Modifying intensity**: Adjust chaos parameters (latency, loss percentage, stress levels)
4. **Changing duration**: Modify the `duration` field

## Example: Custom Workflow

```yaml
apiVersion: chaos-mesh.org/v1alpha1
kind: PodChaos
metadata:
  name: custom-pod-kill
  namespace: your-namespace
spec:
  action: pod-kill
  mode: fixed
  value: "2"  # Kill 2 pods at a time
  selector:
    namespaces:
      - your-namespace
    labelSelectors:
      app: your-app
  scheduler:
    cron: "@every 10m"
  duration: "5s"
```

## Safety Notes

- These workflows are configured to run automatically on a schedule
- Monitor your application's health while chaos experiments are running
- Start with less aggressive experiments and gradually increase intensity
- Always test in non-production environments first
- Keep monitoring and alerting in place

## Troubleshooting

If workflows fail to apply:

1. Check RBAC permissions:
   ```bash
   kubectl auth can-i create podchaos --as=system:serviceaccount:chaos-mesh:chaos-mesh-experimenter -n dockerimagesloaded
   ```

2. Verify Chaos Mesh is running:
   ```bash
   kubectl get pods -n chaos-mesh
   ```

3. Check chaos experiment status:
   ```bash
   kubectl describe podchaos <name> -n dockerimagesloaded
   ```
