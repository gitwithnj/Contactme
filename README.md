# Shopping Site - Kubernetes Application for Minikube

A complete e-commerce shopping site example running on Kubernetes with Minikube. This application demonstrates a microservices architecture with frontend, backend API, PostgreSQL database, and Redis cache.

## Architecture

```
┌─────────────────┐
│   Ingress       │
│  (nginx)        │
└────────┬────────┘
         │
    ┌────┴────┐
    │         │
┌───▼───┐ ┌──▼────┐
│Frontend│ │  API  │
│(nginx) │ │(Node) │
└────────┘ └───┬───┘
               │
        ┌──────┴──────┐
        │             │
    ┌───▼───┐   ┌───▼───┐
    │Postgres│   │ Redis │
    │   DB   │   │ Cache │
    └────────┘   └───────┘
```

## Components

- **Frontend**: Nginx serving a static HTML/JavaScript shopping interface
- **Backend API**: Node.js Express API with REST endpoints
- **PostgreSQL**: Database for products and cart data
- **Redis**: Cache layer for improved performance
- **Ingress**: Nginx ingress controller for external access

## Prerequisites

- Minikube installed and running
- kubectl configured to use minikube
- Podman (or Docker) for container runtime

## Quick Start

### 1. Start Minikube (if not already running)

```bash
minikube start --driver=podman
```

### 2. Enable Ingress Addon

```bash
minikube addons enable ingress
```

Wait for the ingress controller to be ready:
```bash
kubectl wait --namespace ingress-nginx \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=90s
```

### 3. Deploy the Application

Deploy all components in order:

```bash
# Navigate to the shopping-site directory
cd shopping-site

# Create namespace
kubectl apply -f namespace.yaml

# Create configuration
kubectl apply -f configmap.yaml
kubectl apply -f secret.yaml

# Deploy database
kubectl apply -f postgres-deployment.yaml

# Deploy cache
kubectl apply -f redis-deployment.yaml

# Wait for database to be ready
kubectl wait --namespace shopping-site \
  --for=condition=ready pod \
  --selector=app=postgres \
  --timeout=120s

# Deploy backend API
kubectl apply -f backend-deployment.yaml

# Wait for API to be ready
kubectl wait --namespace shopping-site \
  --for=condition=ready pod \
  --selector=app=shopping-api \
  --timeout=120s

# Deploy ingress
kubectl apply -f ingress.yaml
```

### 4. Access the Application

#### Option 1: Using Minikube IP

```bash
# Get minikube IP
MINIKUBE_IP=$(minikube ip)

# Add to /etc/hosts (Linux/Mac) or C:\Windows\System32\drivers\etc\hosts (Windows)
echo "$MINIKUBE_IP shopping.local" | sudo tee -a /etc/hosts

# Access the application
open http://shopping.local
# or
curl http://shopping.local
```

#### Option 2: Using Port Forwarding (Alternative)

```bash
# Forward frontend service
kubectl port-forward -n shopping-site svc/shopping-frontend-service 8080:80

# Access at http://localhost:8080
```

#### Option 3: Using Minikube Service

```bash
# Open in browser
minikube service -n shopping-site shopping-frontend-service

# Or get the URL
minikube service -n shopping-site shopping-frontend-service --url
```

### 5. Verify Deployment

Check all pods are running:

```bash
kubectl get pods -n shopping-site
```

Expected output:
```
NAME                                READY   STATUS    RESTARTS   AGE
postgres-xxxxxxxxxx-xxxxx           1/1     Running   0          2m
redis-xxxxxxxxxx-xxxxx              1/1     Running   0          2m
shopping-api-xxxxxxxxxx-xxxxx       1/1     Running   0          1m
shopping-api-xxxxxxxxxx-xxxxx       1/1     Running   0          1m
shopping-frontend-xxxxxxxxxx-xxxxx  1/1     Running   0          1m
shopping-frontend-xxxxxxxxxx-xxxxx  1/1     Running   0          1m
```

Check services:

```bash
kubectl get svc -n shopping-site
```

Check ingress:

```bash
kubectl get ingress -n shopping-site
```

## API Endpoints

The backend API provides the following endpoints:

- `GET /health` - Health check
- `GET /api/products` - Get all products
- `GET /api/products/:id` - Get product by ID
- `POST /api/cart` - Add item to cart
  ```json
  {
    "user_id": "user123",
    "product_id": 1,
    "quantity": 1
  }
  ```
- `GET /api/cart/:user_id` - Get user's cart

### Test API Directly

```bash
# Get minikube IP
MINIKUBE_IP=$(minikube ip)

# Test health endpoint
curl http://$MINIKUBE_IP/api/health

# Get products
curl http://shopping.local/api/products

# Or via port-forward
kubectl port-forward -n shopping-site svc/shopping-api-service 8080:8080
curl http://localhost:8080/api/products
```

## Troubleshooting

### Pods not starting

```bash
# Check pod status
kubectl get pods -n shopping-site

# Check pod logs
kubectl logs -n shopping-site <pod-name>

# Describe pod for events
kubectl describe pod -n shopping-site <pod-name>
```

### Database connection issues

```bash
# Check postgres logs
kubectl logs -n shopping-site -l app=postgres

# Test database connection
kubectl exec -it -n shopping-site $(kubectl get pod -n shopping-site -l app=postgres -o jsonpath='{.items[0].metadata.name}') -- \
  psql -U shopping_user -d shoppingdb -c "SELECT * FROM products;"
```

### API not responding

```bash
# Check API logs
kubectl logs -n shopping-site -l app=shopping-api

# Check API health
kubectl exec -it -n shopping-site $(kubectl get pod -n shopping-site -l app=shopping-api -o jsonpath='{.items[0].metadata.name}') -- \
  wget -qO- http://localhost:8080/health
```

### Ingress not working

```bash
# Check ingress status
kubectl describe ingress -n shopping-site shopping-ingress

# Check ingress controller
kubectl get pods -n ingress-nginx

# Check ingress controller logs
kubectl logs -n ingress-nginx -l app.kubernetes.io/component=controller
```

### Frontend not loading

```bash
# Check frontend logs
kubectl logs -n shopping-site -l app=shopping-frontend

# Verify frontend service
kubectl get svc -n shopping-site shopping-frontend-service

# Test frontend directly
kubectl port-forward -n shopping-site svc/shopping-frontend-service 8080:80
curl http://localhost:8080
```

## Cleanup

To remove all resources:

```bash
# Delete all resources in namespace
kubectl delete namespace shopping-site

# Or delete individual resources
kubectl delete -f ingress.yaml
kubectl delete -f backend-deployment.yaml
kubectl delete -f redis-deployment.yaml
kubectl delete -f postgres-deployment.yaml
kubectl delete -f secret.yaml
kubectl delete -f configmap.yaml
kubectl delete -f namespace.yaml
```

## Scaling

Scale the frontend:

```bash
kubectl scale deployment shopping-frontend -n shopping-site --replicas=3
```

Scale the API:

```bash
kubectl scale deployment shopping-api -n shopping-site --replicas=3
```

## Resource Limits

The application includes resource requests and limits for all components. Adjust them in the deployment files if needed for your environment.

## Production Considerations

This is a demo application. For production use, consider:

- Use persistent volumes for database and Redis
- Implement proper secrets management (e.g., external secrets operator)
- Add monitoring and logging (Prometheus, Grafana, ELK)
- Implement proper authentication and authorization
- Use TLS/HTTPS for ingress
- Add network policies for security
- Implement proper backup strategies
- Use production-grade images
- Add CI/CD pipelines
- Implement proper health checks and auto-scaling

## Files Structure

```
shopping-site/
├── namespace.yaml              # Namespace definition
├── configmap.yaml              # Configuration data
├── secret.yaml                 # Secrets (DB credentials, etc.)
├── postgres-deployment.yaml    # PostgreSQL database
├── redis-deployment.yaml       # Redis cache
├── backend-deployment.yaml     # Node.js API
├── ingress.yaml                # Ingress configuration
└── README.md                   # This file
```

## License

This is a demo application for educational purposes.
