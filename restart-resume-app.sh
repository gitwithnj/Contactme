#!/bin/bash

# Restart Resume App Service Script
# Restarts the resume-app deployment and waits for pods to be ready

set -e

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

NAMESPACE="dockerimagesloaded"
DEPLOYMENT="resume-app"
SERVICE="resume-app-service"

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  Restart Resume App Service${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Check if namespace exists
if ! kubectl get namespace "$NAMESPACE" > /dev/null 2>&1; then
    echo -e "${RED}✗ Namespace '$NAMESPACE' does not exist${NC}"
    exit 1
fi

# Check if deployment exists
if ! kubectl get deployment "$DEPLOYMENT" -n "$NAMESPACE" > /dev/null 2>&1; then
    echo -e "${RED}✗ Deployment '$DEPLOYMENT' does not exist in namespace '$NAMESPACE'${NC}"
    exit 1
fi

# Show current status
echo -e "${CYAN}Current Pod Status:${NC}"
kubectl get pods -n "$NAMESPACE" -l app=resume-app
echo ""

# Restart the deployment
echo -e "${CYAN}[1/3] Restarting deployment '$DEPLOYMENT'...${NC}"
kubectl rollout restart deployment "$DEPLOYMENT" -n "$NAMESPACE"
echo -e "${GREEN}✓ Restart command issued${NC}"
echo ""

# Wait for rollout to complete
echo -e "${CYAN}[2/3] Waiting for rollout to complete...${NC}"
if kubectl rollout status deployment "$DEPLOYMENT" -n "$NAMESPACE" --timeout=180s; then
    echo -e "${GREEN}✓ Rollout completed successfully${NC}"
else
    echo -e "${YELLOW}⚠ Rollout may still be in progress${NC}"
fi
echo ""

# Wait for pods to be ready
echo -e "${CYAN}[3/3] Waiting for pods to be ready...${NC}"
MAX_WAIT=180
ELAPSED=0
INTERVAL=5

while [ $ELAPSED -lt $MAX_WAIT ]; do
    READY_COUNT=$(kubectl get pods -n "$NAMESPACE" -l app=resume-app -o jsonpath='{range .items[*]}{.status.containerStatuses[0].ready}{"\n"}{end}' 2>/dev/null | grep -c "true" 2>/dev/null || echo "0")
    READY_COUNT=$(echo "$READY_COUNT" | tr -d '\n' | tr -d ' ')
    READY_COUNT=${READY_COUNT:-0}
    READY_COUNT=$((READY_COUNT + 0))
    
    DESIRED_REPLICAS=$(kubectl get deployment "$DEPLOYMENT" -n "$NAMESPACE" -o jsonpath='{.spec.replicas}' 2>/dev/null || echo "2")
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
echo -e "${BLUE}  Final Status${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

echo -e "${CYAN}Pod Status:${NC}"
kubectl get pods -n "$NAMESPACE" -l app=resume-app
echo ""

echo -e "${CYAN}Service Status:${NC}"
kubectl get svc -n "$NAMESPACE" "$SERVICE"
echo ""

# Check if pods are ready
READY_COUNT=$(kubectl get pods -n "$NAMESPACE" -l app=resume-app -o jsonpath='{range .items[*]}{.status.containerStatuses[0].ready}{"\n"}{end}' 2>/dev/null | grep -c "true" 2>/dev/null || echo "0")
READY_COUNT=$(echo "$READY_COUNT" | tr -d '\n' | tr -d ' ')
READY_COUNT=${READY_COUNT:-0}
READY_COUNT=$((READY_COUNT + 0))

if [ $READY_COUNT -gt 0 ]; then
    echo -e "${GREEN}========================================${NC}"
    echo -e "${GREEN}  Resume App Service Restarted Successfully!${NC}"
    echo -e "${GREEN}========================================${NC}"
    echo ""
    echo -e "${CYAN}Access Information:${NC}"
    echo -e "  Port Forward:"
    echo -e "    ${BLUE}kubectl port-forward -n $NAMESPACE svc/$SERVICE 8083:80${NC}"
    echo -e "    Then open: ${BLUE}http://localhost:8083${NC}"
    echo ""
    echo -e "  Minikube Service:"
    echo -e "    ${BLUE}minikube service -n $NAMESPACE $SERVICE${NC}"
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
    echo -e "     ${BLUE}kubectl get pods -n $NAMESPACE${NC}"
    echo ""
    echo -e "  2. Check pod logs:"
    echo -e "     ${BLUE}kubectl logs -n $NAMESPACE -l app=resume-app${NC}"
    echo ""
    echo -e "  3. Check pod description:"
    echo -e "     ${BLUE}kubectl describe pod -n $NAMESPACE -l app=resume-app${NC}"
    echo ""
    exit 1
fi
