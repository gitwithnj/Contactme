#!/bin/bash

# Import Chaos Engineering Workflows Script
# Imports and applies chaos experiments to the cluster

set -e

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

WORKFLOWS_DIR="chaos-workflows"

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  Import Chaos Engineering Workflows${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Check if workflows directory exists
if [ ! -d "$WORKFLOWS_DIR" ]; then
    echo -e "${RED}✗ Workflows directory '$WORKFLOWS_DIR' not found${NC}"
    exit 1
fi

# Count workflow files
WORKFLOW_COUNT=$(find "$WORKFLOWS_DIR" -name "*.yaml" -o -name "*.yml" | wc -l | tr -d ' ')

if [ "$WORKFLOW_COUNT" -eq 0 ]; then
    echo -e "${YELLOW}⚠ No workflow files found in '$WORKFLOWS_DIR'${NC}"
    exit 1
fi

echo -e "${CYAN}Found $WORKFLOW_COUNT workflow file(s)${NC}"
echo ""

# List all workflows
echo -e "${CYAN}Available Workflows:${NC}"
find "$WORKFLOWS_DIR" -name "*.yaml" -o -name "*.yml" | while read -r workflow; do
    echo -e "  ${BLUE}$(basename "$workflow")${NC}"
done
echo ""

# Ask for confirmation
read -p "Do you want to import all workflows? (y/N): " -n 1 -r
echo ""
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${YELLOW}Operation cancelled${NC}"
    exit 0
fi

# Import workflows
echo -e "${CYAN}Importing workflows...${NC}"
echo ""

SUCCESS_COUNT=0
FAILED_COUNT=0
FAILED_FILES=()

for workflow in "$WORKFLOWS_DIR"/*.yaml "$WORKFLOWS_DIR"/*.yml; do
    if [ -f "$workflow" ]; then
        WORKFLOW_NAME=$(basename "$workflow")
        echo -e "${YELLOW}Importing: $WORKFLOW_NAME${NC}"
        
        if kubectl apply -f "$workflow" 2>/dev/null; then
            echo -e "${GREEN}✓ Successfully imported: $WORKFLOW_NAME${NC}"
            SUCCESS_COUNT=$((SUCCESS_COUNT + 1))
        else
            echo -e "${RED}✗ Failed to import: $WORKFLOW_NAME${NC}"
            FAILED_COUNT=$((FAILED_COUNT + 1))
            FAILED_FILES+=("$WORKFLOW_NAME")
        fi
        echo ""
    fi
done

# Summary
echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  Import Summary${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""
echo -e "${GREEN}Successfully imported: $SUCCESS_COUNT${NC}"

if [ $FAILED_COUNT -gt 0 ]; then
    echo -e "${RED}Failed: $FAILED_COUNT${NC}"
    echo ""
    echo -e "${YELLOW}Failed files:${NC}"
    for file in "${FAILED_FILES[@]}"; do
        echo -e "  ${RED}✗ $file${NC}"
    done
else
    echo -e "${GREEN}All workflows imported successfully!${NC}"
fi

echo ""
echo -e "${CYAN}View imported chaos experiments:${NC}"
echo -e "  ${BLUE}kubectl get chaos -A${NC}"
echo ""
echo -e "${CYAN}View specific chaos type:${NC}"
echo -e "  ${BLUE}kubectl get podchaos -n dockerimagesloaded${NC}"
echo -e "  ${BLUE}kubectl get networkchaos -n dockerimagesloaded${NC}"
echo -e "  ${BLUE}kubectl get stresschaos -n dockerimagesloaded${NC}"
echo ""
echo -e "${CYAN}Delete a chaos experiment:${NC}"
echo -e "  ${BLUE}kubectl delete <chaos-type> <name> -n <namespace>${NC}"
echo ""
