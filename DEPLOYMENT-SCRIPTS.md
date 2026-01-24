# Shopping Site - Deployment Scripts

This directory contains scripts to easily start and stop the shopping site application.

## Available Scripts

### `start.sh` - Start Deployment
Deploys all components of the shopping site application to Kubernetes.

**Features:**
- Checks if Minikube is running
- Enables Ingress addon if needed
- Pulls and loads required container images
- Deploys all components in the correct order:
  1. Namespace
  2. ConfigMap
  3. Secrets
  4. Resume HTML ConfigMap (if resume.html exists)
  5. PostgreSQL Database
  6. Redis Cache
  7. Backend API
  8. Frontend
  9. Ingress
- Waits for pods to be ready
- Shows deployment status and access information

**Usage:**
```bash
./start.sh
```

### `check-pods.sh` - Pod Health Check
Checks for pods in CrashLoopBackOff, Error, or other unhealthy states and provides detailed diagnostics.

**Features:**
- Detects CrashLoopBackOff, ImagePullBackOff, ErrImagePull
- Identifies pods in Error or Failed states
- Finds pods stuck in Pending state
- Detects pods with high restart counts
- Shows detailed pod descriptions, events, and logs
- Provides troubleshooting suggestions
- Suggests quick fix commands

**Usage:**
```bash
./check-pods.sh
```

**Note:** This script is automatically run at the end of `start.sh` to verify deployment health.

### `stop.sh` - Stop Deployment
Removes all components of the shopping site application from Kubernetes.

**Features:**
- Prompts for confirmation before deletion
- Deletes all resources in the shopping-site namespace
- Handles cleanup gracefully
- Shows remaining resources (if any)

**Usage:**
```bash
./stop.sh
```

## Quick Start

### Start the Application
```bash
cd /Users/nagadevj/ALLINT/shopping-site
./start.sh
```

### Stop the Application
```bash
cd /Users/nagadevj/ALLINT/shopping-site
./stop.sh
```

## Other Scripts

### `pull-images.sh` - Pull Container Images
Pulls all required container images and loads them into Minikube.

**Usage:**
```bash
./pull-images.sh
```

### `deploy.sh` - Original Deployment Script
The original deployment script (similar to start.sh but with different flow).

**Usage:**
```bash
./deploy.sh
```

## Access the Application

After running `start.sh`, you can access the application using:

### Option 1: Port Forwarding
```bash
kubectl port-forward -n shopping-site svc/shopping-frontend-service 8080:80
```
Then open: http://localhost:8080

### Option 2: Minikube Service
```bash
minikube service -n shopping-site shopping-frontend-service
```

### Option 3: Ingress (if configured)
Add to `/etc/hosts`:
```
$(minikube ip) shopping.local
```
Then open: http://shopping.local

## Troubleshooting

### Check Pod Status
```bash
kubectl get pods -n shopping-site
```

### Check Service Status
```bash
kubectl get svc -n shopping-site
```

### View Pod Logs
```bash
# Frontend
kubectl logs -n shopping-site -l app=shopping-frontend

# Backend API
kubectl logs -n shopping-site -l app=shopping-api

# Database
kubectl logs -n shopping-site -l app=postgres

# Redis
kubectl logs -n shopping-site -l app=redis
```

### Restart a Deployment
```bash
kubectl rollout restart deployment <deployment-name> -n shopping-site
```

### Delete and Recreate
```bash
./stop.sh
./start.sh
```

## Script Details

### start.sh
- **Location:** `/Users/nagadevj/ALLINT/shopping-site/start.sh`
- **Permissions:** Executable (chmod +x)
- **Dependencies:** 
  - Minikube running
  - kubectl configured
  - Podman (for image pulling)

### stop.sh
- **Location:** `/Users/nagadevj/ALLINT/shopping-site/stop.sh`
- **Permissions:** Executable (chmod +x)
- **Safety:** Prompts for confirmation before deletion

## Notes

- The scripts automatically check for required images and pull them if missing
- The start script waits for critical components (like PostgreSQL) to be ready
- The stop script attempts graceful deletion first, then force deletion if needed
- All scripts include colored output for better readability
- Scripts are idempotent - safe to run multiple times
