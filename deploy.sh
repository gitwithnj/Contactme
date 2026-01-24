#!/bin/bash

# Shopping Site Deployment Script for Minikube
# This script deploys the complete shopping site application

set -e

echo "🛍️  Shopping Site - Kubernetes Deployment Script"
echo "=================================================="

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Check if minikube is running
echo -e "${YELLOW}Checking Minikube status...${NC}"
if ! minikube status > /dev/null 2>&1; then
    echo -e "${RED}Minikube is not running. Starting Minikube...${NC}"
    minikube start --driver=podman
else
    echo -e "${GREEN}Minikube is running${NC}"
fi

# Enable ingress addon
echo -e "${YELLOW}Enabling Ingress addon...${NC}"
minikube addons enable ingress

# Wait for ingress controller
echo -e "${YELLOW}Waiting for Ingress controller to be ready...${NC}"
kubectl wait --namespace ingress-nginx \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=90s || echo -e "${YELLOW}Ingress controller may still be starting...${NC}"

# Get the directory where the script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$SCRIPT_DIR"

# Deploy in order
echo -e "${YELLOW}Creating namespace...${NC}"
kubectl apply -f namespace.yaml

echo -e "${YELLOW}Creating ConfigMap...${NC}"
kubectl apply -f configmap.yaml

echo -e "${YELLOW}Creating Secrets...${NC}"
kubectl apply -f secret.yaml

echo -e "${YELLOW}Deploying PostgreSQL...${NC}"
kubectl apply -f postgres-deployment.yaml

echo -e "${YELLOW}Deploying Redis...${NC}"
kubectl apply -f redis-deployment.yaml

echo -e "${YELLOW}Waiting for PostgreSQL to be ready...${NC}"
kubectl wait --namespace shopping-site \
  --for=condition=ready pod \
  --selector=app=postgres \
  --timeout=120s || echo -e "${YELLOW}PostgreSQL may still be starting...${NC}"

echo -e "${YELLOW}Deploying Backend API...${NC}"
kubectl apply -f backend-deployment.yaml

echo -e "${YELLOW}Waiting for API to be ready...${NC}"
sleep 10
kubectl wait --namespace shopping-site \
  --for=condition=ready pod \
  --selector=app=shopping-api \
  --timeout=120s || echo -e "${YELLOW}API may still be starting...${NC}"

echo -e "${YELLOW}Deploying Ingress...${NC}"
kubectl apply -f ingress.yaml

# Wait a bit for everything to stabilize
echo -e "${YELLOW}Waiting for all pods to be ready...${NC}"
sleep 15

# Show status
echo -e "${GREEN}Deployment complete!${NC}"
echo ""
echo "Pod Status:"
kubectl get pods -n shopping-site

echo ""
echo "Service Status:"
kubectl get svc -n shopping-site

echo ""
echo "Ingress Status:"
kubectl get ingress -n shopping-site

# Get minikube IP
MINIKUBE_IP=$(minikube ip)
echo ""
echo -e "${GREEN}=================================================="
echo "Access the application:"
echo "=================================================="
echo "Minikube IP: $MINIKUBE_IP"
echo ""
echo "Add to /etc/hosts (Linux/Mac) or hosts file (Windows):"
echo "  $MINIKUBE_IP shopping.local"
echo ""
echo "Then access:"
echo "  http://shopping.local"
echo ""
echo "Or use port forwarding:"
echo "  kubectl port-forward -n shopping-site svc/shopping-frontend-service 8080:80"
echo "  Then open: http://localhost:8080"
echo ""
echo "Or use minikube service:"
echo "  minikube service -n shopping-site shopping-frontend-service"
echo -e "==================================================${NC}"
