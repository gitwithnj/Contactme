#!/bin/bash

# Pull Chaos Mesh Images Script
# Pulls Chaos Mesh images using Podman and loads them into Minikube

set -e

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  Pull Chaos Mesh Images${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Chaos Mesh images to pull (based on current deployment)
IMAGES=(
    "ghcr.io/chaos-mesh/chaos-mesh:v2.8.1"
    "ghcr.io/chaos-mesh/chaos-daemon:v2.8.1"
    "ghcr.io/chaos-mesh/chaos-dashboard:v2.8.1"
    "ghcr.io/chaos-mesh/chaos-coredns:v0.2.8"
)

TOTAL=${#IMAGES[@]}
CURRENT=0

for IMAGE in "${IMAGES[@]}"; do
    CURRENT=$((CURRENT + 1))
    echo -e "${CYAN}[$CURRENT/$TOTAL] Processing: $IMAGE${NC}"
    
    # Pull image using Podman
    echo -e "  ${YELLOW}Pulling image with Podman...${NC}"
    if podman pull "$IMAGE" 2>/dev/null; then
        echo -e "  ${GREEN}✓ Image pulled successfully${NC}"
    else
        echo -e "  ${YELLOW}⚠ Warning: Failed to pull image with podman${NC}"
        echo -e "  ${YELLOW}  Attempting to continue...${NC}"
    fi
    
    # Load image into Minikube
    echo -e "  ${YELLOW}Loading image into Minikube...${NC}"
    if minikube image load "$IMAGE" 2>/dev/null; then
        echo -e "  ${GREEN}✓ Image loaded into Minikube${NC}"
    else
        echo -e "  ${RED}✗ Failed to load image into Minikube${NC}"
        echo -e "  ${YELLOW}  You may need to pull the image manually or check network connectivity${NC}"
    fi
    
    echo ""
done

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  Verification${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Verify images in Minikube
echo -e "${CYAN}Checking images in Minikube:${NC}"
for IMAGE in "${IMAGES[@]}"; do
    if minikube image ls | grep -q "$IMAGE"; then
        echo -e "  ${GREEN}✓ $IMAGE${NC}"
    else
        echo -e "  ${RED}✗ $IMAGE (not found)${NC}"
    fi
done

echo ""
echo -e "${CYAN}Updating Chaos Mesh deployment to use local images...${NC}"

# Update Helm values to use imagePullPolicy: Never
echo -e "${YELLOW}Updating imagePullPolicy to Never...${NC}"
helm upgrade chaos-mesh chaos-mesh/chaos-mesh \
    --namespace=chaos-mesh \
    --reuse-values \
    --set chaosDaemon.runtime=containerd \
    --set chaosDaemon.socketPath=/run/containerd/containerd.sock \
    --set imagePullPolicy=Never \
    --set chaosDaemon.imagePullPolicy=Never \
    --set dashboard.imagePullPolicy=Never \
    --set dnsServer.imagePullPolicy=Never \
    > /dev/null 2>&1

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ Helm values updated${NC}"
else
    echo -e "${YELLOW}⚠ Could not update Helm values automatically${NC}"
    echo -e "${YELLOW}  You may need to manually set imagePullPolicy: Never in the deployments${NC}"
fi

echo ""
echo -e "${CYAN}Next Steps:${NC}"
echo -e "  1. Restart Chaos Mesh pods to use the loaded images:"
echo -e "     ${BLUE}kubectl rollout restart deployment -n chaos-mesh${NC}"
echo ""
echo -e "  2. Check pod status:"
echo -e "     ${BLUE}kubectl get pods -n chaos-mesh${NC}"
echo ""
echo -e "  3. Wait for all pods to be ready:"
echo -e "     ${BLUE}kubectl wait --for=condition=ready pod -l app.kubernetes.io/instance=chaos-mesh -n chaos-mesh --timeout=300s${NC}"
echo ""
echo -e "  4. Access Chaos Dashboard:"
echo -e "     ${BLUE}kubectl port-forward -n chaos-mesh svc/chaos-dashboard 2333:2333${NC}"
echo -e "     Then open: ${BLUE}http://localhost:2333${NC}"
echo ""
