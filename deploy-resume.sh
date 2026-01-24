#!/bin/bash

# Resume Deployment Script
# This script creates the ConfigMap from resume.html and deploys the resume

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
echo -e "${BLUE}  Resume Deployment Script${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Check if resume.html exists
if [ ! -f "resume.html" ]; then
    echo -e "${RED}Error: resume.html not found!${NC}"
    exit 1
fi

# Step 1: Create namespace
echo -e "${CYAN}[1/4] Creating namespace...${NC}"
kubectl apply -f - <<EOF
apiVersion: v1
kind: Namespace
metadata:
  name: resume
  labels:
    name: resume
EOF
echo -e "${GREEN}✓ Namespace created${NC}"
echo ""

# Step 2: Create ConfigMap from resume.html
echo -e "${CYAN}[2/4] Creating ConfigMap from resume.html...${NC}"
kubectl create configmap resume-html \
  --from-file=index.html=resume.html \
  -n resume \
  --dry-run=client -o yaml | kubectl apply -f -
echo -e "${GREEN}✓ ConfigMap created${NC}"
echo ""

# Step 3: Deploy resume application
echo -e "${CYAN}[3/4] Deploying resume application...${NC}"
kubectl apply -f resume.yaml
echo -e "${GREEN}✓ Resume deployment created${NC}"
echo ""

# Step 4: Wait for pods to be ready
echo -e "${CYAN}[4/4] Waiting for pods to be ready...${NC}"
MAX_WAIT=120
ELAPSED=0
INTERVAL=5

while [ $ELAPSED -lt $MAX_WAIT ]; do
    READY_COUNT=$(kubectl get pods -n resume -l app=resume -o jsonpath='{range .items[*]}{.status.containerStatuses[0].ready}{"\n"}{end}' 2>/dev/null | grep -c "true" 2>/dev/null || echo "0")
    READY_COUNT=$(echo "$READY_COUNT" | tr -d '\n' | tr -d ' ')
    READY_COUNT=${READY_COUNT:-0}
    READY_COUNT=$((READY_COUNT + 0))
    
    DESIRED_REPLICAS=$(kubectl get deployment resume -n resume -o jsonpath='{.spec.replicas}' 2>/dev/null || echo "2")
    DESIRED_REPLICAS=$(echo "$DESIRED_REPLICAS" | tr -d '\n' | tr -d ' ')
    DESIRED_REPLICAS=${DESIRED_REPLICAS:-2}
    DESIRED_REPLICAS=$((DESIRED_REPLICAS + 0))
    
    if [ $READY_COUNT -ge $DESIRED_REPLICAS ]; then
        echo -e "${GREEN}✓ All resume pods are ready ($READY_COUNT/$DESIRED_REPLICAS)${NC}"
        break
    fi
    
    echo -e "${YELLOW}  Waiting... ($READY_COUNT/$DESIRED_REPLICAS ready) [${ELAPSED}s/${MAX_WAIT}s]${NC}"
    sleep $INTERVAL
    ELAPSED=$((ELAPSED + INTERVAL))
done

# Final status
echo ""
echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  Resume Pod Status${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""
kubectl get pods -n resume
echo ""

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  Service & Ingress Status${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""
kubectl get svc -n resume
echo ""
kubectl get ingress -n resume
echo ""

# Check if pods are ready
READY_COUNT=$(kubectl get pods -n resume -l app=resume -o jsonpath='{range .items[*]}{.status.containerStatuses[0].ready}{"\n"}{end}' 2>/dev/null | grep -c "true" 2>/dev/null || echo "0")
READY_COUNT=$(echo "$READY_COUNT" | tr -d '\n' | tr -d ' ')
READY_COUNT=${READY_COUNT:-0}
READY_COUNT=$((READY_COUNT + 0))

if [ $READY_COUNT -gt 0 ]; then
    echo -e "${GREEN}========================================${NC}"
    echo -e "${GREEN}  Resume Deployment Successful!${NC}"
    echo -e "${GREEN}========================================${NC}"
    echo ""
    echo -e "${CYAN}Access Information:${NC}"
    echo -e "  Port Forward:"
    echo -e "    ${BLUE}kubectl port-forward -n resume svc/resume-service 8082:80${NC}"
    echo -e "    Then open: ${BLUE}http://localhost:8082${NC}"
    echo ""
    echo -e "  Minikube Service:"
    echo -e "    ${BLUE}minikube service -n resume resume-service${NC}"
    echo ""
    MINIKUBE_IP=$(minikube ip 2>/dev/null || echo "")
    if [ -n "$MINIKUBE_IP" ]; then
        echo -e "  Ingress (add to /etc/hosts):"
        echo -e "    ${BLUE}echo \"$MINIKUBE_IP resume.local\" | sudo tee -a /etc/hosts${NC}"
        echo -e "    Then open: ${BLUE}http://resume.local${NC}"
    fi
    echo ""
else
    echo -e "${YELLOW}⚠ Pods may still be starting. Check status with:${NC}"
    echo -e "${BLUE}kubectl get pods -n resume${NC}"
    echo ""
fi
