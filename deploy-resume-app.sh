#!/bin/bash

# Resume App Deployment Script
# Pulls docwithnj/resume-app from Docker using Podman and deploys it

set -e

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Get the directory where the script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$SCRIPT_DIR"

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  Resume App Deployment Script${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Step 1: Create namespace
echo -e "${CYAN}[1/5] Creating namespace 'dockerimagesloaded'...${NC}"
kubectl apply -f dockerimagesloaded-namespace.yaml
echo -e "${GREEN}✓ Namespace created${NC}"
echo ""

# Step 2: Pull Docker image using Podman
echo -e "${CYAN}[2/5] Pulling Docker image 'docwithnj/resume-app' using Podman...${NC}"
IMAGE_NAME="docwithnj/resume-app:latest"

if podman pull "$IMAGE_NAME" 2>/dev/null; then
    echo -e "${GREEN}✓ Image pulled successfully${NC}"
else
    echo -e "${YELLOW}⚠ Warning: Failed to pull image with podman${NC}"
    echo -e "${YELLOW}  Attempting to continue...${NC}"
fi
echo ""

# Step 3: Load image into Minikube
echo -e "${CYAN}[3/5] Loading image into Minikube...${NC}"
if minikube image load "$IMAGE_NAME" 2>/dev/null; then
    echo -e "${GREEN}✓ Image loaded into Minikube${NC}"
else
    echo -e "${YELLOW}⚠ Warning: Failed to load image into Minikube${NC}"
    echo -e "${YELLOW}  The deployment will attempt to pull the image from Docker Hub${NC}"
fi
echo ""

# Step 4: Deploy the application
echo -e "${CYAN}[4/5] Deploying resume-app application...${NC}"
kubectl apply -f resume-app-deployment.yaml
echo -e "${GREEN}✓ Deployment created${NC}"
echo ""

# Step 5: Wait for pods to be ready
echo -e "${CYAN}[5/5] Waiting for pods to be ready...${NC}"
MAX_WAIT=180
ELAPSED=0
INTERVAL=5

while [ $ELAPSED -lt $MAX_WAIT ]; do
    READY_COUNT=$(kubectl get pods -n dockerimagesloaded -l app=resume-app -o jsonpath='{range .items[*]}{.status.containerStatuses[0].ready}{"\n"}{end}' 2>/dev/null | grep -c "true" 2>/dev/null || echo "0")
    READY_COUNT=$(echo "$READY_COUNT" | tr -d '\n' | tr -d ' ')
    READY_COUNT=${READY_COUNT:-0}
    READY_COUNT=$((READY_COUNT + 0))
    
    DESIRED_REPLICAS=$(kubectl get deployment resume-app -n dockerimagesloaded -o jsonpath='{.spec.replicas}' 2>/dev/null || echo "2")
    DESIRED_REPLICAS=$(echo "$DESIRED_REPLICAS" | tr -d '\n' | tr -d ' ')
    DESIRED_REPLICAS=${DESIRED_REPLICAS:-2}
    DESIRED_REPLICAS=$((DESIRED_REPLICAS + 0))
    
    if [ $READY_COUNT -ge $DESIRED_REPLICAS ]; then
        echo -e "${GREEN}✓ All pods are ready ($READY_COUNT/$DESIRED_REPLICAS)${NC}"
        break
    fi
    
    echo -e "${YELLOW}  Waiting... ($READY_COUNT/$DESIRED_REPLICAS ready) [${ELAPSED}s/${MAX_WAIT}s]${NC}"
    sleep $INTERVAL
    ELAPSED=$((ELAPSED + INTERVAL))
done

# Final status
echo ""
echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  Resume App Pod Status${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""
kubectl get pods -n dockerimagesloaded
echo ""

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  Service & Ingress Status${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""
kubectl get svc -n dockerimagesloaded
echo ""
kubectl get ingress -n dockerimagesloaded
echo ""

# Check if pods are ready
READY_COUNT=$(kubectl get pods -n dockerimagesloaded -l app=resume-app -o jsonpath='{range .items[*]}{.status.containerStatuses[0].ready}{"\n"}{end}' 2>/dev/null | grep -c "true" 2>/dev/null || echo "0")
READY_COUNT=$(echo "$READY_COUNT" | tr -d '\n' | tr -d ' ')
READY_COUNT=${READY_COUNT:-0}
READY_COUNT=$((READY_COUNT + 0))

if [ $READY_COUNT -gt 0 ]; then
    echo -e "${GREEN}========================================${NC}"
    echo -e "${GREEN}  Resume App Deployment Successful!${NC}"
    echo -e "${GREEN}========================================${NC}"
    echo ""
    echo -e "${CYAN}Access Information:${NC}"
    echo -e "  Port Forward:"
    echo -e "    ${BLUE}kubectl port-forward -n dockerimagesloaded svc/resume-app-service 8083:80${NC}"
    echo -e "    Then open: ${BLUE}http://localhost:8083${NC}"
    echo ""
    echo -e "  Minikube Service:"
    echo -e "    ${BLUE}minikube service -n dockerimagesloaded resume-app-service${NC}"
    echo ""
    MINIKUBE_IP=$(minikube ip 2>/dev/null || echo "")
    if [ -n "$MINIKUBE_IP" ]; then
        echo -e "  Ingress (add to /etc/hosts):"
        echo -e "    ${BLUE}echo \"$MINIKUBE_IP resume-app.local\" | sudo tee -a /etc/hosts${NC}"
        echo -e "    Then open: ${BLUE}http://resume-app.local${NC}"
    fi
    echo ""
else
    echo -e "${YELLOW}⚠ Pods may still be starting or have issues.${NC}"
    echo ""
    echo -e "${YELLOW}Troubleshooting:${NC}"
    echo -e "  1. Check pod status:"
    echo -e "     ${BLUE}kubectl get pods -n dockerimagesloaded${NC}"
    echo ""
    echo -e "  2. Check pod logs:"
    echo -e "     ${BLUE}kubectl logs -n dockerimagesloaded -l app=resume-app${NC}"
    echo ""
    echo -e "  3. Check pod description:"
    echo -e "     ${BLUE}kubectl describe pod -n dockerimagesloaded -l app=resume-app${NC}"
    echo ""
    echo -e "  4. Verify image is available:"
    echo -e "     ${BLUE}minikube image ls | grep resume-app${NC}"
    echo ""
fi
