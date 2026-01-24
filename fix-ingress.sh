#!/bin/bash

# Fix Ingress Webhook Issue
# This script temporarily disables the ingress webhook to allow ingress creation

set -e

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  Fix Ingress Webhook Issue${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Check if webhook exists
if kubectl get validatingwebhookconfigurations ingress-nginx-admission > /dev/null 2>&1; then
    echo -e "${YELLOW}Found ingress-nginx-admission webhook${NC}"
    echo -e "${YELLOW}This webhook can block ingress creation if the controller isn't ready${NC}"
    echo ""
    read -p "Do you want to temporarily disable the webhook? (y/N): " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo -e "${YELLOW}Deleting webhook...${NC}"
        kubectl delete validatingwebhookconfigurations ingress-nginx-admission
        echo -e "${GREEN}✓ Webhook disabled${NC}"
        echo ""
        echo -e "${YELLOW}Now you can create the ingress:${NC}"
        echo -e "${BLUE}kubectl apply -f ingress.yaml${NC}"
        echo ""
        echo -e "${YELLOW}Note: The webhook will be recreated when the ingress controller is ready${NC}"
    else
        echo -e "${YELLOW}Operation cancelled${NC}"
    fi
else
    echo -e "${GREEN}Webhook not found or already disabled${NC}"
    echo -e "${YELLOW}You can try creating the ingress now:${NC}"
    echo -e "${BLUE}kubectl apply -f ingress.yaml${NC}"
fi

echo ""
