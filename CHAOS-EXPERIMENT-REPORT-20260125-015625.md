# Chaos Engineering Experiment Report

**Report Date:** January 25, 2026 01:56:35  
**Cluster:** minikube
**Target Application:** resume-app  
**Namespace:** dockerimagesloaded  
**Chaos Mesh Version:** 2.8.1

---

## Executive Summary

This report documents the chaos engineering experiments conducted on the `resume-app` application using Chaos Mesh.

### Quick Statistics

- **Total Experiments:** 12
  - Pod Chaos: 4
  - Network Chaos: 4
  - Stress Chaos: 3
  - Scheduled: 1
- **Application Pods:** 2 (Ready: 2)
- **Application Status:** ✅ Healthy

---

## Active Experiments

### Pod Chaos Experiments

```
NAME                                  AGE
resume-app-pod-failure                18m
resume-app-pod-kill                   19m
scheduled-resume-app-pod-kill-85nfm   11m
scheduled-resume-app-pod-kill-bc6mq   16m
```

### Network Chaos Experiments

```
NAME                           ACTION      DURATION
resume-app-bandwidth-limit     bandwidth   2m
resume-app-network-delay       delay       30s
resume-app-network-loss        loss        30s
resume-app-network-partition   partition   1m
```

### Stress Chaos Experiments

```
NAME                       DURATION
resume-app-cpu-stress      1m
resume-app-io-stress       45s
resume-app-memory-stress   1m
```

### Scheduled Experiments

```
NAME                            AGE
scheduled-resume-app-pod-kill   18m
```

---

## Application Status

### Current Pods

```
NAME                          READY   STATUS    RESTARTS      AGE
resume-app-55cc46dc8f-jfbb8   1/1     Running   0             11m
resume-app-55cc46dc8f-qh2k7   1/1     Running   1 (18m ago)   19m
```

### Deployment Status

```
NAME         READY   UP-TO-DATE   AVAILABLE   AGE
resume-app   2/2     2            2           4h54m
```

---

## Recent Events

```
37s         Warning   Failed              networkchaos/resume-app-bandwidth-limit        Failed to apply chaos: failed to apply for pod dockerimagesloaded/resume-app-55cc46dc8f-qh2k7: unable to flush ip sets for pod resume-app-55cc46dc8f-qh2k7
37s         Warning   Failed              networkchaos/resume-app-bandwidth-limit        Failed to apply chaos: failed to apply for pod dockerimagesloaded/resume-app-55cc46dc8f-qh2k7: unable to flush ip sets for pod resume-app-55cc46dc8f-qh2k7
37s         Normal    Updated             networkchaos/resume-app-bandwidth-limit        Successfully update desiredPhase of resource
37s         Normal    TimeUp              networkchaos/resume-app-bandwidth-limit        Time up according to the duration
37s         Normal    Updated             networkchaos/resume-app-bandwidth-limit        Successfully update records of resource
37s         Normal    Updated             networkchaos/resume-app-bandwidth-limit        Successfully update records of resource
30s         Warning   Failed              networkchaos/resume-app-network-delay          Failed to apply chaos: failed to apply for pod dockerimagesloaded/resume-app-55cc46dc8f-qh2k7: unable to flush ip sets for pod resume-app-55cc46dc8f-qh2k7
30s         Warning   Failed              networkchaos/resume-app-network-delay          Failed to apply chaos: failed to apply for pod dockerimagesloaded/resume-app-55cc46dc8f-qh2k7: unable to flush ip sets for pod resume-app-55cc46dc8f-qh2k7
30s         Normal    Updated             networkchaos/resume-app-network-delay          Successfully update records of resource
30s         Normal    Updated             networkchaos/resume-app-network-delay          Successfully update records of resource
```

---

## Detailed Experiment Information


### podChaos Details

#### podchaos.chaos-mesh.org/resume-app-pod-failure

```yaml
apiVersion: chaos-mesh.org/v1alpha1
kind: PodChaos
metadata:
  annotations:
    kubectl.kubernetes.io/last-applied-configuration: |
      {"apiVersion":"chaos-mesh.org/v1alpha1","kind":"PodChaos","metadata":{"annotations":{},"name":"resume-app-pod-failure","namespace":"dockerimagesloaded"},"spec":{"action":"pod-failure","duration":"2m","mode":"fixed","selector":{"labelSelectors":{"app":"resume-app"},"namespaces":["dockerimagesloaded"]},"value":"1"}}
  creationTimestamp: "2026-01-24T19:57:43Z"
  finalizers:
  - chaos-mesh/records
  generation: 8
  name: resume-app-pod-failure
  namespace: dockerimagesloaded
  resourceVersion: "95944"
  uid: 9c2ccdad-62d7-49f4-a50a-5a2703f15f0b
spec:
  action: pod-failure
  duration: 2m
  mode: fixed
  selector:
    labelSelectors:
      app: resume-app
    namespaces:
    - dockerimagesloaded
  value: "1"
status:
  conditions:
  - status: "True"
    type: Selected
  - status: "False"
    type: AllInjected
  - status: "True"
    type: AllRecovered
  - status: "False"
    type: Paused
  experiment:
    containerRecords:
    - events:
      - operation: Apply
        timestamp: "2026-01-24T19:57:43Z"
        type: Succeeded
      - operation: Recover
        timestamp: "2026-01-24T19:59:43Z"
        type: Succeeded
      id: dockerimagesloaded/resume-app-55cc46dc8f-qh2k7
      injectedCount: 1
      phase: Not Injected
      recoveredCount: 1
      selectorKey: .
    desiredPhase: Stop
```

#### podchaos.chaos-mesh.org/resume-app-pod-kill

```yaml
apiVersion: chaos-mesh.org/v1alpha1
kind: PodChaos
metadata:
  annotations:
    kubectl.kubernetes.io/last-applied-configuration: |
      {"apiVersion":"chaos-mesh.org/v1alpha1","kind":"PodChaos","metadata":{"annotations":{},"name":"resume-app-pod-kill","namespace":"dockerimagesloaded"},"spec":{"action":"pod-kill","mode":"one","selector":{"labelSelectors":{"app":"resume-app"},"namespaces":["dockerimagesloaded"]}}}
  creationTimestamp: "2026-01-24T19:57:15Z"
  finalizers:
  - chaos-mesh/records
  generation: 5
  name: resume-app-pod-kill
  namespace: dockerimagesloaded
  resourceVersion: "95167"
  uid: 2af7b1f2-fc8d-4421-9660-ae12bb91cb83
spec:
  action: pod-kill
  mode: one
  selector:
    labelSelectors:
      app: resume-app
    namespaces:
    - dockerimagesloaded
status:
  conditions:
  - status: "True"
    type: Selected
  - status: "True"
    type: AllInjected
  - status: "False"
    type: AllRecovered
  - status: "False"
    type: Paused
  experiment:
    containerRecords:
    - events:
      - operation: Apply
        timestamp: "2026-01-24T19:57:15Z"
        type: Succeeded
      id: dockerimagesloaded/resume-app-55cc46dc8f-8pxk4
      injectedCount: 1
      phase: Injected
      recoveredCount: 0
      selectorKey: .
    desiredPhase: Run
```

#### podchaos.chaos-mesh.org/scheduled-resume-app-pod-kill-85nfm

```yaml
apiVersion: chaos-mesh.org/v1alpha1
kind: PodChaos
metadata:
  annotations:
    experiment.chaos-mesh.org/pause: "true"
  creationTimestamp: "2026-01-24T20:05:00Z"
  finalizers:
  - chaos-mesh/records
  generation: 8
  labels:
    managed-by: scheduled-resume-app-pod-kill
  name: scheduled-resume-app-pod-kill-85nfm
  namespace: dockerimagesloaded
  ownerReferences:
  - apiVersion: chaos-mesh.org/v1alpha1
    blockOwnerDeletion: true
    controller: true
    kind: Schedule
    name: scheduled-resume-app-pod-kill
    uid: 3b519671-79c4-4831-abab-5d431d475eb2
  resourceVersion: "96977"
  uid: 66ea73c5-eded-44af-88a0-47d44c1b9885
spec:
  action: pod-kill
  mode: one
  selector:
    labelSelectors:
      app: resume-app
    namespaces:
    - dockerimagesloaded
status:
  conditions:
  - status: "True"
    type: Selected
  - status: "True"
    type: AllInjected
  - status: "False"
    type: AllRecovered
  - status: "True"
    type: Paused
  experiment:
    containerRecords:
    - events:
      - operation: Apply
        timestamp: "2026-01-24T20:05:00Z"
        type: Succeeded
      id: dockerimagesloaded/resume-app-55cc46dc8f-vkwc4
      injectedCount: 1
      phase: Injected
      recoveredCount: 0
```

#### podchaos.chaos-mesh.org/scheduled-resume-app-pod-kill-bc6mq

```yaml
apiVersion: chaos-mesh.org/v1alpha1
kind: PodChaos
metadata:
  annotations:
    experiment.chaos-mesh.org/pause: "true"
  creationTimestamp: "2026-01-24T20:00:00Z"
  finalizers:
  - chaos-mesh/records
  generation: 10
  labels:
    managed-by: scheduled-resume-app-pod-kill
  name: scheduled-resume-app-pod-kill-bc6mq
  namespace: dockerimagesloaded
  ownerReferences:
  - apiVersion: chaos-mesh.org/v1alpha1
    blockOwnerDeletion: true
    controller: true
    kind: Schedule
    name: scheduled-resume-app-pod-kill
    uid: 3b519671-79c4-4831-abab-5d431d475eb2
  resourceVersion: "96994"
  uid: 80001f2e-73cd-40f3-9e56-451f98f5a44e
spec:
  action: pod-kill
  mode: one
  selector:
    labelSelectors:
      app: resume-app
    namespaces:
    - dockerimagesloaded
status:
  conditions:
  - status: "True"
    type: Selected
  - status: "True"
    type: AllInjected
  - status: "False"
    type: AllRecovered
  - status: "True"
    type: Paused
  experiment:
    containerRecords:
    - events:
      - operation: Apply
        timestamp: "2026-01-24T20:00:00Z"
        type: Succeeded
      id: dockerimagesloaded/resume-app-55cc46dc8f-57pth
      injectedCount: 1
      phase: Injected
      recoveredCount: 0
```


### networkChaos Details

#### networkchaos.chaos-mesh.org/resume-app-bandwidth-limit

```yaml
apiVersion: chaos-mesh.org/v1alpha1
kind: NetworkChaos
metadata:
  annotations:
    kubectl.kubernetes.io/last-applied-configuration: |
      {"apiVersion":"chaos-mesh.org/v1alpha1","kind":"NetworkChaos","metadata":{"annotations":{},"name":"resume-app-bandwidth-limit","namespace":"dockerimagesloaded"},"spec":{"action":"bandwidth","bandwidth":{"buffer":16000,"limit":2097152,"rate":"1mbps"},"duration":"2m","mode":"one","selector":{"labelSelectors":{"app":"resume-app"},"namespaces":["dockerimagesloaded"]}}}
  creationTimestamp: "2026-01-24T19:57:33Z"
  finalizers:
  - chaos-mesh/records
  generation: 28
  name: resume-app-bandwidth-limit
  namespace: dockerimagesloaded
  resourceVersion: "97408"
  uid: 6fb6c4bf-6c05-4995-8fe2-f801d91bf538
spec:
  action: bandwidth
  bandwidth:
    buffer: 16000
    limit: 2097152
    rate: 1mbps
  direction: to
  duration: 2m
  mode: one
  selector:
    labelSelectors:
      app: resume-app
    namespaces:
    - dockerimagesloaded
status:
  conditions:
  - status: "True"
    type: Selected
  - status: "False"
    type: AllInjected
  - status: "False"
    type: AllRecovered
  - status: "False"
    type: Paused
  experiment:
    containerRecords:
    - events:
      - message: 'failed to apply for pod dockerimagesloaded/resume-app-55cc46dc8f-qh2k7:
          unable to flush ip sets for pod resume-app-55cc46dc8f-qh2k7'
        operation: Apply
        timestamp: "2026-01-24T19:57:33Z"
        type: Failed
      - message: 'failed to apply for pod dockerimagesloaded/resume-app-55cc46dc8f-qh2k7:
          unable to flush ip sets for pod resume-app-55cc46dc8f-qh2k7'
        operation: Apply
        timestamp: "2026-01-24T19:57:33Z"
```

#### networkchaos.chaos-mesh.org/resume-app-network-delay

```yaml
apiVersion: chaos-mesh.org/v1alpha1
kind: NetworkChaos
metadata:
  annotations:
    kubectl.kubernetes.io/last-applied-configuration: |
      {"apiVersion":"chaos-mesh.org/v1alpha1","kind":"NetworkChaos","metadata":{"annotations":{},"name":"resume-app-network-delay","namespace":"dockerimagesloaded"},"spec":{"action":"delay","delay":{"correlation":"100","jitter":"0ms","latency":"100ms"},"duration":"30s","mode":"one","selector":{"labelSelectors":{"app":"resume-app"},"namespaces":["dockerimagesloaded"]}}}
  creationTimestamp: "2026-01-24T19:57:35Z"
  finalizers:
  - chaos-mesh/records
  generation: 28
  name: resume-app-network-delay
  namespace: dockerimagesloaded
  resourceVersion: "97424"
  uid: 31b9d6ed-c87b-4bfc-b942-af3fade354c4
spec:
  action: delay
  delay:
    correlation: "100"
    jitter: 0ms
    latency: 100ms
  direction: to
  duration: 30s
  mode: one
  selector:
    labelSelectors:
      app: resume-app
    namespaces:
    - dockerimagesloaded
status:
  conditions:
  - status: "True"
    type: Selected
  - status: "False"
    type: AllInjected
  - status: "False"
    type: AllRecovered
  - status: "False"
    type: Paused
  experiment:
    containerRecords:
    - events:
      - message: 'failed to apply for pod dockerimagesloaded/resume-app-55cc46dc8f-qh2k7:
          unable to flush ip sets for pod resume-app-55cc46dc8f-qh2k7'
        operation: Apply
        timestamp: "2026-01-24T19:57:35Z"
        type: Failed
      - message: 'failed to apply for pod dockerimagesloaded/resume-app-55cc46dc8f-qh2k7:
          unable to flush ip sets for pod resume-app-55cc46dc8f-qh2k7'
        operation: Apply
        timestamp: "2026-01-24T19:57:35Z"
```

#### networkchaos.chaos-mesh.org/resume-app-network-loss

```yaml
apiVersion: chaos-mesh.org/v1alpha1
kind: NetworkChaos
metadata:
  annotations:
    kubectl.kubernetes.io/last-applied-configuration: |
      {"apiVersion":"chaos-mesh.org/v1alpha1","kind":"NetworkChaos","metadata":{"annotations":{},"name":"resume-app-network-loss","namespace":"dockerimagesloaded"},"spec":{"action":"loss","duration":"30s","loss":{"correlation":"25","loss":"10"},"mode":"one","selector":{"labelSelectors":{"app":"resume-app"},"namespaces":["dockerimagesloaded"]}}}
  creationTimestamp: "2026-01-24T19:58:22Z"
  finalizers:
  - chaos-mesh/records
  generation: 26
  name: resume-app-network-loss
  namespace: dockerimagesloaded
  resourceVersion: "96544"
  uid: 5267490e-cb70-4525-94be-45e48754e1b0
spec:
  action: loss
  direction: to
  duration: 30s
  loss:
    correlation: "25"
    loss: "10"
  mode: one
  selector:
    labelSelectors:
      app: resume-app
    namespaces:
    - dockerimagesloaded
status:
  conditions:
  - status: "True"
    type: Selected
  - status: "False"
    type: AllInjected
  - status: "False"
    type: AllRecovered
  - status: "False"
    type: Paused
  experiment:
    containerRecords:
    - events:
      - message: 'failed to apply for pod dockerimagesloaded/resume-app-55cc46dc8f-qh2k7:
          unable to flush ip sets for pod resume-app-55cc46dc8f-qh2k7'
        operation: Apply
        timestamp: "2026-01-24T19:58:22Z"
        type: Failed
      - message: 'failed to apply for pod dockerimagesloaded/resume-app-55cc46dc8f-qh2k7:
          unable to flush ip sets for pod resume-app-55cc46dc8f-qh2k7'
        operation: Apply
        timestamp: "2026-01-24T19:58:22Z"
        type: Failed
```

#### networkchaos.chaos-mesh.org/resume-app-network-partition

```yaml
apiVersion: chaos-mesh.org/v1alpha1
kind: NetworkChaos
metadata:
  annotations:
    kubectl.kubernetes.io/last-applied-configuration: |
      {"apiVersion":"chaos-mesh.org/v1alpha1","kind":"NetworkChaos","metadata":{"annotations":{},"name":"resume-app-network-partition","namespace":"dockerimagesloaded"},"spec":{"action":"partition","direction":"both","duration":"1m","mode":"one","selector":{"labelSelectors":{"app":"resume-app"},"namespaces":["dockerimagesloaded"]}}}
  creationTimestamp: "2026-01-24T19:57:40Z"
  finalizers:
  - chaos-mesh/records
  generation: 25
  name: resume-app-network-partition
  namespace: dockerimagesloaded
  resourceVersion: "96013"
  uid: 527fefb9-246e-4898-bdb4-26db7cc4c982
spec:
  action: partition
  direction: both
  duration: 1m
  mode: one
  selector:
    labelSelectors:
      app: resume-app
    namespaces:
    - dockerimagesloaded
status:
  conditions:
  - status: "True"
    type: AllRecovered
  - status: "False"
    type: Paused
  - status: "True"
    type: Selected
  - status: "False"
    type: AllInjected
  experiment:
    containerRecords:
    - events:
      - message: 'failed to apply for pod dockerimagesloaded/resume-app-55cc46dc8f-57pth:
          unable to flush ip sets for pod resume-app-55cc46dc8f-57pth'
        operation: Apply
        timestamp: "2026-01-24T19:57:40Z"
        type: Failed
      - message: 'failed to apply for pod dockerimagesloaded/resume-app-55cc46dc8f-57pth:
          unable to flush ip sets for pod resume-app-55cc46dc8f-57pth'
        operation: Apply
        timestamp: "2026-01-24T19:57:40Z"
        type: Failed
      - message: 'failed to apply for pod dockerimagesloaded/resume-app-55cc46dc8f-57pth:
          unable to flush ip sets for pod resume-app-55cc46dc8f-57pth'
        operation: Apply
```


### stressChaos Details

#### stresschaos.chaos-mesh.org/resume-app-cpu-stress

```yaml
apiVersion: chaos-mesh.org/v1alpha1
kind: StressChaos
metadata:
  annotations:
    kubectl.kubernetes.io/last-applied-configuration: |
      {"apiVersion":"chaos-mesh.org/v1alpha1","kind":"StressChaos","metadata":{"annotations":{},"name":"resume-app-cpu-stress","namespace":"dockerimagesloaded"},"spec":{"duration":"1m","mode":"one","selector":{"labelSelectors":{"app":"resume-app"},"namespaces":["dockerimagesloaded"]},"stressors":{"cpu":{"load":80,"options":["--cpu 2","--timeout 60s"],"workers":2}}}}
  creationTimestamp: "2026-01-24T19:57:26Z"
  finalizers:
  - chaos-mesh/records
  generation: 22
  name: resume-app-cpu-stress
  namespace: dockerimagesloaded
  resourceVersion: "96091"
  uid: c7a3f673-69d4-4f4f-8bb8-535ae5aad170
spec:
  duration: 1m
  mode: one
  selector:
    labelSelectors:
      app: resume-app
    namespaces:
    - dockerimagesloaded
  stressors:
    cpu:
      load: 80
      options:
      - --cpu 2
      - --timeout 60s
      workers: 2
status:
  conditions:
  - status: "True"
    type: Selected
  - status: "False"
    type: AllInjected
  - status: "True"
    type: AllRecovered
  - status: "False"
    type: Paused
  experiment:
    containerRecords:
    - events:
      - message: 'rpc error: code = Unknown desc = expected containerd:// but got
          docker://f877'
        operation: Apply
        timestamp: "2026-01-24T19:57:26Z"
        type: Failed
      - message: 'rpc error: code = Unknown desc = expected containerd:// but got
          docker://f877'
        operation: Apply
```

#### stresschaos.chaos-mesh.org/resume-app-io-stress

```yaml
apiVersion: chaos-mesh.org/v1alpha1
kind: StressChaos
metadata:
  annotations:
    kubectl.kubernetes.io/last-applied-configuration: |
      {"apiVersion":"chaos-mesh.org/v1alpha1","kind":"StressChaos","metadata":{"annotations":{},"name":"resume-app-io-stress","namespace":"dockerimagesloaded"},"spec":{"duration":"45s","mode":"one","selector":{"labelSelectors":{"app":"resume-app"},"namespaces":["dockerimagesloaded"]},"stressors":{"memory":{"options":["--vm 1","--vm-bytes 128M","--vm-keep","--timeout 60s"],"size":"128MB","workers":1}}}}
  creationTimestamp: "2026-01-24T19:58:29Z"
  finalizers:
  - chaos-mesh/records
  generation: 21
  name: resume-app-io-stress
  namespace: dockerimagesloaded
  resourceVersion: "96063"
  uid: 5cbdc4a5-d3cf-436f-b9c9-8864bcc55c77
spec:
  duration: 45s
  mode: one
  selector:
    labelSelectors:
      app: resume-app
    namespaces:
    - dockerimagesloaded
  stressors:
    memory:
      oomScoreAdj: 0
      options:
      - --vm 1
      - --vm-bytes 128M
      - --vm-keep
      - --timeout 60s
      size: 128MB
      workers: 1
status:
  conditions:
  - status: "True"
    type: Selected
  - status: "False"
    type: AllInjected
  - status: "True"
    type: AllRecovered
  - status: "False"
    type: Paused
  experiment:
    containerRecords:
    - events:
      - message: 'rpc error: code = Unknown desc = expected containerd:// but got
          docker://f877'
        operation: Apply
        timestamp: "2026-01-24T19:58:29Z"
        type: Failed
```

#### stresschaos.chaos-mesh.org/resume-app-memory-stress

```yaml
apiVersion: chaos-mesh.org/v1alpha1
kind: StressChaos
metadata:
  annotations:
    kubectl.kubernetes.io/last-applied-configuration: |
      {"apiVersion":"chaos-mesh.org/v1alpha1","kind":"StressChaos","metadata":{"annotations":{},"name":"resume-app-memory-stress","namespace":"dockerimagesloaded"},"spec":{"duration":"1m","mode":"one","selector":{"labelSelectors":{"app":"resume-app"},"namespaces":["dockerimagesloaded"]},"stressors":{"memory":{"options":["--vm 1","--vm-bytes 256M","--timeout 60s"],"size":"256MB","workers":1}}}}
  creationTimestamp: "2026-01-24T19:58:25Z"
  finalizers:
  - chaos-mesh/records
  generation: 21
  name: resume-app-memory-stress
  namespace: dockerimagesloaded
  resourceVersion: "96057"
  uid: c7b27f41-1220-4ef9-9c76-983af6fe2df2
spec:
  duration: 1m
  mode: one
  selector:
    labelSelectors:
      app: resume-app
    namespaces:
    - dockerimagesloaded
  stressors:
    memory:
      oomScoreAdj: 0
      options:
      - --vm 1
      - --vm-bytes 256M
      - --timeout 60s
      size: 256MB
      workers: 1
status:
  conditions:
  - status: "False"
    type: Paused
  - status: "True"
    type: Selected
  - status: "False"
    type: AllInjected
  - status: "True"
    type: AllRecovered
  experiment:
    containerRecords:
    - events:
      - message: 'rpc error: code = Unknown desc = expected containerd:// but got
          docker://f877'
        operation: Apply
        timestamp: "2026-01-24T19:58:25Z"
        type: Failed
      - message: 'rpc error: code = Unknown desc = expected containerd:// but got
```

---

## Recommendations

1. Review experiment results and application behavior
2. Monitor application health during experiments
3. Document any issues or unexpected behaviors
4. Adjust experiment parameters based on findings

---

**Report Generated:** January 25, 2026 01:57:13  
**Generated By:** generate-chaos-report.sh  
**Cluster:** minikube

