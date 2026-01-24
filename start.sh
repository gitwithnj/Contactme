#!/bin/bash

# Shopping Site - Start Deployment Script
# This script deploys all components of the shopping site application

set -e

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Get the directory where the script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$SCRIPT_DIR"

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  Shopping Site - Start Deployment${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Check if minikube is running
echo -e "${YELLOW}Checking Minikube status...${NC}"
if ! minikube status > /dev/null 2>&1; then
    echo -e "${RED}Minikube is not running. Starting Minikube...${NC}"
    minikube start --driver=podman
else
    echo -e "${GREEN}✓ Minikube is running${NC}"
fi

# Enable ingress addon
#echo -e "${YELLOW}Checking Ingress addon...${NC}"
#if ! minikube addons list | grep -q "ingress.*enabled"; then
#    echo -e "${YELLOW}Enabling Ingress addon...${NC}"
#    minikube addons enable ingress
#    echo -e "${YELLOW}Waiting for Ingress controller to be ready...${NC}"
#    kubectl wait --namespace ingress-nginx \
#      --for=condition=ready pod \
#      --selector=app.kubernetes.io/component=controller \
#      --timeout=90s 2>/dev/null || echo -e "${YELLOW}Ingress controller may still be startng...${NC}"#else
#    echo -e "${GREEN}✓ Ingress addon is enabled${NC}"
#fi

# Check if images are loaded
echo -e "${YELLOW}Checking required images...${NC}"
REQUIRED_IMAGES=("postgres:15-alpine" "redis:7-alpine" "node:18-alpine" "nginx:alpine" "busybox:latest")
MISSING_IMAGES=()

for image in "${REQUIRED_IMAGES[@]}"; do
    if ! minikube image ls 2>/dev/null | grep -q "$image"; then
        MISSING_IMAGES+=("$image")
    fi
done

if [ ${#MISSING_IMAGES[@]} -gt 0 ]; then
    echo -e "${YELLOW}Some images are missing. Pulling and loading images...${NC}"
    if [ -f "$SCRIPT_DIR/pull-images.sh" ]; then
        "$SCRIPT_DIR/pull-images.sh"
    else
        echo -e "${YELLOW}Running pull-images.sh...${NC}"
        for image in "${MISSING_IMAGES[@]}"; do
            echo "  Pulling: $image"
            podman pull "$image" 2>/dev/null || true
            minikube image load "$image" 2>/dev/null || true
        done
    fi
else
    echo -e "${GREEN}✓ All required images are available${NC}"
fi

# Deploy in order
echo ""
echo -e "${BLUE}Deploying components...${NC}"
echo ""

# 1. Namespace
echo -e "${YELLOW}[1/8] Creating namespace...${NC}"
kubectl apply -f namespace.yaml
echo -e "${GREEN}✓ Namespace created${NC}"

# 2. ConfigMap
echo -e "${YELLOW}[2/8] Creating ConfigMap...${NC}"
kubectl apply -f configmap.yaml
echo -e "${GREEN}✓ ConfigMap created${NC}"

# 3. Secrets
echo -e "${YELLOW}[3/8] Creating Secrets...${NC}"
kubectl apply -f secret.yaml
echo -e "${GREEN}✓ Secrets created${NC}"

# 4. Resume HTML ConfigMap (if resume.html exists)
if [ -f "resume.html" ]; then
    echo -e "${YELLOW}[4/8] Creating Resume HTML ConfigMap...${NC}"
    kubectl create configmap resume-html --from-file=resume.html=resume.html -n shopping-site --dry-run=client -o yaml | kubectl apply -f -
    echo -e "${GREEN}✓ Resume HTML ConfigMap created${NC}"
else
    echo -e "${YELLOW}[4/8] Skipping Resume HTML ConfigMap (resume.html not found)${NC}"
fi

# 5. PostgreSQL
echo -e "${YELLOW}[5/8] Deploying PostgreSQL...${NC}"
kubectl apply -f postgres-deployment.yaml
echo -e "${GREEN}✓ PostgreSQL deployment created${NC}"

# 6. Redis
echo -e "${YELLOW}[6/8] Deploying Redis...${NC}"
kubectl apply -f redis-deployment.yaml
echo -e "${GREEN}✓ Redis deployment created${NC}"

# 7. Wait for database
echo -e "${YELLOW}[7/8] Waiting for PostgreSQL to be ready...${NC}"
if kubectl wait --namespace shopping-site \
  --for=condition=ready pod \
  --selector=app=postgres \
  --timeout=120s 2>/dev/null; then
    echo -e "${GREEN}✓ PostgreSQL is ready${NC}"
else
    echo -e "${YELLOW}⚠ PostgreSQL may still be starting...${NC}"
fi

# 8. Backend API
echo -e "${YELLOW}[8/8] Deploying Backend API...${NC}"
kubectl apply -f backend-deployment.yaml
echo -e "${GREEN}✓ Backend API deployment created${NC}"

# 9. Ingress (optional - may fail if ingress controller not ready)
if [ -f "ingress.yaml" ]; then
    echo -e "${YELLOW}[9/9] Deploying Ingress...${NC}"
    if kubectl apply -f ingress.yaml 2>/dev/null; then
        echo -e "${GREEN}✓ Ingress created${NC}"
    else
        # Try disabling webhook if it exists and blocking
        if kubectl get validatingwebhookconfigurations ingress-nginx-admission > /dev/null 2>&1; then
            echo -e "${YELLOW}  Webhook is blocking ingress creation. Temporarily disabling...${NC}"
            kubectl delete validatingwebhookconfigurations ingress-nginx-admission 2>/dev/null || true
            sleep 2
            if kubectl apply -f ingress.yaml 2>/dev/null; then
                echo -e "${GREEN}✓ Ingress created (after disabling webhook)${NC}"
            else
                echo -e "${YELLOW}⚠ Ingress creation still failed${NC}"
                echo -e "${YELLOW}  You can try deploying ingress later:${NC}"
                echo -e "${YELLOW}  kubectl apply -f ingress.yaml${NC}"
            fi
        else
            echo -e "${YELLOW}⚠ Ingress creation failed${NC}"
            echo -e "${YELLOW}  You can try deploying ingress later:${NC}"
            echo -e "${YELLOW}  kubectl apply -f ingress.yaml${NC}"
        fi
    fi
fi

# Wait for pods to be ready
echo ""
echo -e "${YELLOW}Waiting for all pods to be ready...${NC}"
sleep 10

# Check pod status
echo ""
echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  Deployment Status${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""
kubectl get pods -n shopping-site

echo ""
echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  Service Status${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""
kubectl get svc -n shopping-site

if [ -f "ingress.yaml" ]; then
    echo ""
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}  Ingress Status${NC}"
    echo -e "${BLUE}========================================${NC}"
    echo ""
    kubectl get ingress -n shopping-site
fi

# Get access information
MINIKUBE_IP=$(minikube ip)
echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  Access Information${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo -e "Minikube IP: ${BLUE}$MINIKUBE_IP${NC}"
echo ""
echo -e "To access the application:"
echo -e "  1. Port Forward:"
echo -e "     ${BLUE}kubectl port-forward -n shopping-site svc/shopping-frontend-service 8080:80${NC}"
echo -e "     Then open: ${BLUE}http://localhost:8080${NC}"
echo ""
echo -e "  2. Minikube Service:"
echo -e "     ${BLUE}minikube service -n shopping-site shopping-frontend-service${NC}"
echo ""
if [ -f "ingress.yaml" ]; then
    echo -e "  3. Ingress (add to /etc/hosts):"
    echo -e "     ${BLUE}echo \"$MINIKUBE_IP shopping.local\" | sudo tee -a /etc/hosts${NC}"
    echo -e "     Then open: ${BLUE}http://shopping.local${NC}"
fi
echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  Deployment Complete!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""

# Run pod health check
echo -e "${YELLOW}Running pod health check...${NC}"
if [ -f "$SCRIPT_DIR/check-pods.sh" ]; then
    "$SCRIPT_DIR/check-pods.sh" || {
        echo ""
        echo -e "${YELLOW}Some pods may have issues. Check the output above for details.${NC}"
        echo -e "${YELLOW}You can run the health check again with:${NC}"
        echo -e "${BLUE}./check-pods.sh${NC}"
    }
else
    echo -e "${YELLOW}Health check script not found. Skipping...${NC}"
fi