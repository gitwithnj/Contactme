#!/bin/bash

# Shopping Site - Stop Deployment Script
# This script stops and removes all components of the shopping site application

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
echo -e "${BLUE}  Shopping Site - Stop Deployment${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Check if namespace exists
if ! kubectl get namespace shopping-site > /dev/null 2>&1; then
    echo -e "${YELLOW}Namespace 'shopping-site' does not exist. Nothing to stop.${NC}"
    exit 0
fi

# Ask for confirmation
echo -e "${YELLOW}This will delete all resources in the 'shopping-site' namespace.${NC}"
read -p "Are you sure you want to continue? (y/N): " -n 1 -r
echo ""
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${YELLOW}Operation cancelled.${NC}"
    exit 0
fi

echo ""
echo -e "${YELLOW}Stopping and removing components...${NC}"
echo ""

# Option 1: Delete namespace (removes everything)
echo -e "${YELLOW}Deleting namespace 'shopping-site' (this will remove all resources)...${NC}"
kubectl delete namespace shopping-site --wait=true --timeout=60s 2>/dev/null || {
    echo -e "${YELLOW}Namespace deletion timed out or failed. Trying individual resource deletion...${NC}"
    
    # Option 2: Delete resources individually
    echo -e "${YELLOW}Deleting resources individually...${NC}"
    
    # Delete in reverse order
    if [ -f "ingress.yaml" ]; then
        echo -e "  Deleting Ingress..."
        kubectl delete -f ingress.yaml --ignore-not-found=true 2>/dev/null || true
    fi
    
    echo -e "  Deleting Backend API..."
    kubectl delete -f backend-deployment.yaml --ignore-not-found=true 2>/dev/null || true
    
    echo -e "  Deleting Redis..."
    kubectl delete -f redis-deployment.yaml --ignore-not-found=true 2>/dev/null || true
    
    echo -e "  Deleting PostgreSQL..."
    kubectl delete -f postgres-deployment.yaml --ignore-not-found=true 2>/dev/null || true
    
    echo -e "  Deleting Secrets..."
    kubectl delete -f secret.yaml --ignore-not-found=true 2>/dev/null || true
    
    echo -e "  Deleting ConfigMaps..."
    kubectl delete -f configmap.yaml --ignore-not-found=true 2>/dev/null || true
    kubectl delete configmap resume-html -n shopping-site --ignore-not-found=true 2>/dev/null || true
    
    echo -e "  Deleting Namespace..."
    kubectl delete -f namespace.yaml --ignore-not-found=true 2>/dev/null || true
    
    # Force delete namespace if it still exists
    if kubectl get namespace shopping-site > /dev/null 2>&1; then
        echo -e "${YELLOW}Force deleting namespace...${NC}"
        kubectl delete namespace shopping-site --force --grace-period=0 2>/dev/null || true
    fi
}

# Wait a bit for cleanup
sleep 3

# Verify deletion
if kubectl get namespace shopping-site > /dev/null 2>&1; then
    echo -e "${RED}⚠ Warning: Namespace still exists. Some resources may not have been deleted.${NC}"
    echo -e "${YELLOW}You may need to manually clean up remaining resources.${NC}"
else
    echo -e "${GREEN}✓ Namespace 'shopping-site' has been deleted${NC}"
fi

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  All resources stopped and removed!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""

# Show remaining resources (if any)
REMAINING=$(kubectl get all -n shopping-site 2>/dev/null | wc -l || echo "0")
if [ "$REMAINING" -gt "1" ]; then
    echo -e "${YELLOW}Remaining resources in namespace:${NC}"
    kubectl get all -n shopping-site 2>/dev/null || true
else
    echo -e "${GREEN}No remaining resources found.${NC}"
fi

echo ""
