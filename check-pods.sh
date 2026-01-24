#!/bin/bash

# Shopping Site - Pod Health Check Script
# This script checks for pods in CrashLoopBackOff, Error, or other unhealthy states

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

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  Shopping Site - Pod Health Check${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Check if namespace exists
if ! kubectl get namespace shopping-site > /dev/null 2>&1; then
    echo -e "${RED}Namespace 'shopping-site' does not exist.${NC}"
    echo -e "${YELLOW}Run ./start.sh first to deploy the application.${NC}"
    exit 1
fi

# Get all pods in the namespace
echo -e "${CYAN}Checking pod status...${NC}"
echo ""

# Get pods with their status
PODS=$(kubectl get pods -n shopping-site -o jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.status.phase}{"\t"}{range .status.containerStatuses[*]}{.state.waiting.reason}{"\t"}{.state.terminated.reason}{"\t"}{.restartCount}{"\n"}{end}{end}')

# Track problematic pods
PROBLEM_PODS=()
CRASHLOOP_PODS=()
ERROR_PODS=()
PENDING_PODS=()
RESTARTING_PODS=()

# Check each pod
while IFS=$'\t' read -r pod_name phase waiting_reason terminated_reason restart_count; do
    if [ -z "$pod_name" ]; then
        continue
    fi
    
    # Get full pod status
    POD_STATUS=$(kubectl get pod "$pod_name" -n shopping-site -o jsonpath='{.status.containerStatuses[0].state}' 2>/dev/null || echo "")
    
    # Check for CrashLoopBackOff
    if [[ "$waiting_reason" == "CrashLoopBackOff" ]] || [[ "$waiting_reason" == "ImagePullBackOff" ]] || [[ "$waiting_reason" == "ErrImagePull" ]]; then
        CRASHLOOP_PODS+=("$pod_name|$waiting_reason")
        PROBLEM_PODS+=("$pod_name")
    fi
    
    # Check for Error state
    if [[ "$phase" == "Failed" ]] || [[ "$terminated_reason" == "Error" ]]; then
        ERROR_PODS+=("$pod_name|$terminated_reason")
        PROBLEM_PODS+=("$pod_name")
    fi
    
    # Check for Pending
    if [[ "$phase" == "Pending" ]] && [[ "$waiting_reason" != "" ]]; then
        PENDING_PODS+=("$pod_name|$waiting_reason")
        PROBLEM_PODS+=("$pod_name")
    fi
    
    # Check for high restart count
    if [ -n "$restart_count" ] && [ "$restart_count" -gt 5 ]; then
        RESTARTING_PODS+=("$pod_name|$restart_count")
        if [[ ! " ${PROBLEM_PODS[@]} " =~ " ${pod_name} " ]]; then
            PROBLEM_PODS+=("$pod_name")
        fi
    fi
done <<< "$PODS"

# Display overall status
echo -e "${CYAN}Overall Pod Status:${NC}"
kubectl get pods -n shopping-site
echo ""

# Summary
TOTAL_PROBLEMS=$((${#CRASHLOOP_PODS[@]} + ${#ERROR_PODS[@]} + ${#PENDING_PODS[@]} + ${#RESTARTING_PODS[@]}))

if [ $TOTAL_PROBLEMS -eq 0 ]; then
    echo -e "${GREEN}✓ All pods are healthy!${NC}"
    echo ""
    exit 0
fi

# Display problems found
echo -e "${RED}========================================${NC}"
echo -e "${RED}  Problems Detected: $TOTAL_PROBLEMS${NC}"
echo -e "${RED}========================================${NC}"
echo ""

# CrashLoopBackOff pods
if [ ${#CRASHLOOP_PODS[@]} -gt 0 ]; then
    echo -e "${RED}⚠ CrashLoopBackOff / ImagePull Issues: ${#CRASHLOOP_PODS[@]}${NC}"
    for pod_info in "${CRASHLOOP_PODS[@]}"; do
        IFS='|' read -r pod_name reason <<< "$pod_info"
        echo -e "  ${RED}•${NC} ${CYAN}$pod_name${NC} - ${YELLOW}$reason${NC}"
    done
    echo ""
fi

# Error pods
if [ ${#ERROR_PODS[@]} -gt 0 ]; then
    echo -e "${RED}⚠ Error State: ${#ERROR_PODS[@]}${NC}"
    for pod_info in "${ERROR_PODS[@]}"; do
        IFS='|' read -r pod_name reason <<< "$pod_info"
        echo -e "  ${RED}•${NC} ${CYAN}$pod_name${NC} - ${YELLOW}$reason${NC}"
    done
    echo ""
fi

# Pending pods
if [ ${#PENDING_PODS[@]} -gt 0 ]; then
    echo -e "${YELLOW}⚠ Pending: ${#PENDING_PODS[@]}${NC}"
    for pod_info in "${PENDING_PODS[@]}"; do
        IFS='|' read -r pod_name reason <<< "$pod_info"
        echo -e "  ${YELLOW}•${NC} ${CYAN}$pod_name${NC} - ${YELLOW}$reason${NC}"
    done
    echo ""
fi

# High restart count
if [ ${#RESTARTING_PODS[@]} -gt 0 ]; then
    echo -e "${YELLOW}⚠ High Restart Count: ${#RESTARTING_PODS[@]}${NC}"
    for pod_info in "${RESTARTING_PODS[@]}"; do
        IFS='|' read -r pod_name count <<< "$pod_info"
        echo -e "  ${YELLOW}•${NC} ${CYAN}$pod_name${NC} - ${YELLOW}Restarted $count times${NC}"
    done
    echo ""
fi

# Detailed information for each problematic pod
echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  Detailed Information${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

for pod_name in "${PROBLEM_PODS[@]}"; do
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${CYAN}Pod: $pod_name${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    
    # Pod describe
    echo -e "${YELLOW}Pod Description:${NC}"
    kubectl describe pod "$pod_name" -n shopping-site | tail -20
    echo ""
    
    # Pod events
    echo -e "${YELLOW}Recent Events:${NC}"
    kubectl get events -n shopping-site --field-selector involvedObject.name="$pod_name" --sort-by='.lastTimestamp' | tail -5
    echo ""
    
    # Pod logs (if container is running)
    CONTAINER_STATUS=$(kubectl get pod "$pod_name" -n shopping-site -o jsonpath='{.status.containerStatuses[0].ready}' 2>/dev/null || echo "false")
    if [ "$CONTAINER_STATUS" == "true" ]; then
        echo -e "${YELLOW}Recent Logs (last 20 lines):${NC}"
        kubectl logs "$pod_name" -n shopping-site --tail=20 2>/dev/null || echo "  (Unable to retrieve logs)"
    else
        # Try to get logs from previous container
        echo -e "${YELLOW}Previous Container Logs (last 20 lines):${NC}"
        kubectl logs "$pod_name" -n shopping-site --previous --tail=20 2>/dev/null || echo "  (No previous logs available)"
    fi
    echo ""
    echo ""
done

# Provide troubleshooting suggestions
echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  Troubleshooting Suggestions${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

if [ ${#CRASHLOOP_PODS[@]} -gt 0 ]; then
    echo -e "${YELLOW}For CrashLoopBackOff / ImagePull issues:${NC}"
    echo -e "  1. Check if images are available:"
    echo -e "     ${CYAN}minikube image ls${NC}"
    echo -e "  2. Pull missing images:"
    echo -e "     ${CYAN}./pull-images.sh${NC}"
    echo -e "  3. Check pod logs:"
    echo -e "     ${CYAN}kubectl logs <pod-name> -n shopping-site${NC}"
    echo -e "  4. Check pod description:"
    echo -e "     ${CYAN}kubectl describe pod <pod-name> -n shopping-site${NC}"
    echo ""
fi

if [ ${#PENDING_PODS[@]} -gt 0 ]; then
    echo -e "${YELLOW}For Pending pods:${NC}"
    echo -e "  1. Check resource availability:"
    echo -e "     ${CYAN}kubectl describe node${NC}"
    echo -e "  2. Check if init containers are running:"
    echo -e "     ${CYAN}kubectl get pod <pod-name> -n shopping-site -o jsonpath='{.status.initContainerStatuses[*].state}'${NC}"
    echo ""
fi

if [ ${#RESTARTING_PODS[@]} -gt 0 ]; then
    echo -e "${YELLOW}For pods with high restart count:${NC}"
    echo -e "  1. Check application logs:"
    echo -e "     ${CYAN}kubectl logs <pod-name> -n shopping-site --previous${NC}"
    echo -e "  2. Check resource limits:"
    echo -e "     ${CYAN}kubectl describe pod <pod-name> -n shopping-site | grep -A 5 'Limits'${NC}"
    echo -e "  3. Restart the deployment:"
    echo -e "     ${CYAN}kubectl rollout restart deployment <deployment-name> -n shopping-site${NC}"
    echo ""
fi

# Quick fix commands
echo -e "${GREEN}Quick Fix Commands:${NC}"
echo -e "  ${CYAN}# Restart all deployments${NC}"
echo -e "  ${BLUE}kubectl rollout restart deployment -n shopping-site${NC}"
echo ""
echo -e "  ${CYAN}# Delete problematic pods (they will be recreated)${NC}"
for pod_name in "${PROBLEM_PODS[@]}"; do
    echo -e "  ${BLUE}kubectl delete pod $pod_name -n shopping-site${NC}"
done
echo ""

# Exit with error code if problems found
exit 1
