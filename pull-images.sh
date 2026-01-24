#!/bin/bash

# Podman Commands to Pull Images for Shopping Site
# This script pulls all required images and loads them into Minikube

set -e

echo "🐳 Pulling images with Podman for Shopping Site"
echo "================================================"

# Images used in the application
IMAGES=(
    "postgres:15-alpine"
    "redis:7-alpine"
    "node:18-alpine"
    "nginx:alpine"
    "busybox:latest"
)

echo ""
echo "📥 Pulling images with Podman..."
echo ""

for image in "${IMAGES[@]}"; do
    echo "Pulling: $image"
    podman pull "$image"
    echo "✅ Pulled: $image"
    echo ""
done

echo "================================================"
echo "📦 Loading images into Minikube..."
echo ""

# Load images into Minikube
for image in "${IMAGES[@]}"; do
    echo "Loading: $image into Minikube"
    minikube image load "$image"
    echo "✅ Loaded: $image"
    echo ""
done

echo "================================================"
echo "✅ All images pulled and loaded into Minikube!"
echo ""
echo "You can verify with:"
echo "  minikube image ls"
echo "  podman images"
