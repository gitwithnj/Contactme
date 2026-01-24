#!/bin/bash

# Get Chaos Mesh Service Account Token Script
# Retrieves the token for the chaos-mesh-experimenter service account

set -e

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

NAMESPACE="chaos-mesh"
SERVICE_ACCOUNT="chaos-mesh-experimenter"

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  Get Chaos Mesh Service Account Token${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Check if service account exists
if ! kubectl get serviceaccount "$SERVICE_ACCOUNT" -n "$NAMESPACE" > /dev/null 2>&1; then
    echo -e "${RED}✗ Service account '$SERVICE_ACCOUNT' does not exist in namespace '$NAMESPACE'${NC}"
    exit 1
fi

echo -e "${CYAN}Service Account:${NC} $SERVICE_ACCOUNT"
echo -e "${CYAN}Namespace:${NC} $NAMESPACE"
echo ""

# Create token (valid for 1 year)
echo -e "${YELLOW}Generating token (valid for 1 year)...${NC}"
TOKEN=$(kubectl create token "$SERVICE_ACCOUNT" -n "$NAMESPACE" --duration=8760h)

if [ -z "$TOKEN" ]; then
    echo -e "${RED}✗ Failed to generate token${NC}"
    exit 1
fi

echo ""
echo -e "${GREEN}✓ Token generated successfully${NC}"
echo ""
echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  Token${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""
echo -e "${CYAN}$TOKEN${NC}"
echo ""
echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  Usage Examples${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""
echo -e "${CYAN}1. Use with kubectl:${NC}"
echo -e "   ${BLUE}kubectl --token=$TOKEN --server=https://<k8s-api-server> get pods -n dockerimagesloaded${NC}"
echo ""
echo -e "${CYAN}2. Use with curl:${NC}"
echo -e "   ${BLUE}curl -k -H \"Authorization: Bearer $TOKEN\" https://<k8s-api-server>/api/v1/namespaces/dockerimagesloaded/pods${NC}"
echo ""
echo -e "${CYAN}3. Export as environment variable:${NC}"
echo -e "   ${BLUE}export CHAOS_MESH_TOKEN=\"$TOKEN\"${NC}"
echo ""
echo -e "${CYAN}4. Save to file:${NC}"
echo -e "   ${BLUE}echo \"$TOKEN\" > chaos-mesh-token.txt${NC}"
echo ""
echo -e "${YELLOW}Note:${NC} This token is valid for 1 year (8760 hours)"
echo -e "${YELLOW}      ${NC} Keep this token secure and do not share it publicly"
echo ""
