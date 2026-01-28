# Terraform - Deploy All Applications to Minikube

This Terraform configuration deploys all Kubernetes resources to Minikube:

- **Namespaces:** shopping-site, dockerimagesloaded, resume, chaos-mesh
- **Shopping Site:** ConfigMap, Secret, PostgreSQL, Redis, Backend API, Ingress
- **Resume App:** Deployment, Service, Ingress (dockerimagesloaded namespace)
- **Resume:** ConfigMap (from resume.html), Deployment, Service, Ingress (resume namespace)
- **Chaos Mesh:** Helm chart (optional)
- **RBAC:** Chaos Mesh experimenter ServiceAccount, ClusterRole, RoleBindings (optional)
- **Chaos Workflows:** Pod/Network/Stress chaos experiments (optional)

## Prerequisites

1. **Minikube** running:
   ```bash
   minikube start --driver=podman
   minikube addons enable ingress
   ```

2. **kubectl** configured to use Minikube:
   ```bash
   kubectl config use-context minikube
   ```

3. **Helm** installed (for Chaos Mesh).

4. **Pre-load images** (for resume-app with imagePullPolicy: Never):
   ```bash
   ./pull-images.sh          # Shopping site images
   ./pull-chaos-mesh-images.sh  # Chaos Mesh images (if deploying Chaos Mesh)
   # Load resume-app image: minikube image load docwithnj/resume-app:latest
   ```

## Usage

```bash
cd terraform

# Initialize Terraform (downloads providers)
terraform init

# Review plan
terraform plan

# Apply all deployments
terraform apply

# Apply with auto-approve
terraform apply -auto-approve
```

## Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `kube_config_path` | Path to kubeconfig | `""` (use default) |
| `deploy_chaos_mesh` | Deploy Chaos Mesh via Helm | `true` |
| `deploy_chaos_workflows` | Deploy chaos workflows | `true` |
| `chaos_mesh_helm_chart_version` | Chaos Mesh chart version | `"2.8.1"` |
| `chaos_daemon_runtime` | Container runtime for Chaos Mesh | `"containerd"` |
| `chaos_daemon_socket_path` | Runtime socket path | `"/run/containerd/containerd.sock"` |

Override via CLI or `terraform.tfvars`:

```bash
terraform apply -var="deploy_chaos_mesh=false"
```

## Deploy Order (Dependencies)

1. Namespaces
2. Shopping site: ConfigMap, Secret → Postgres, Redis → Backend → Ingress
3. Resume: ConfigMap (resume-html) → Deployment, Service, Ingress
4. Resume App: Deployment, Service, Ingress
5. Chaos Mesh (Helm)
6. RBAC (after Chaos Mesh)
7. Chaos Workflows (after RBAC and resume-app)

## Outputs

- `namespaces` – Created namespace names
- `shopping_site_ingress_host` – shopping.local
- `resume_app_ingress_host` – resume-app.local
- `resume_ingress_host` – resume.local
- `access_commands` – Useful kubectl port-forward and /etc/hosts commands

## Destroy

```bash
terraform destroy
```

Note: Chaos Mesh and some CRDs may require manual cleanup:

```bash
helm uninstall chaos-mesh -n chaos-mesh
kubectl delete namespace chaos-mesh
```

## File Layout

```
terraform/
├── main.tf           # Providers, locals
├── variables.tf      # Input variables
├── versions.tf       # Terraform & provider version constraints
├── namespaces.tf     # Namespaces
├── shopping-site.tf  # Shopping site resources (kubectl apply for multi-doc YAML)
├── resume.tf         # Resume app (resume namespace)
├── resume-app.tf     # Resume app (dockerimagesloaded namespace)
├── chaos-mesh.tf     # Chaos Mesh Helm release
├── rbac.tf           # Chaos Mesh RBAC
├── chaos-workflows.tf # Chaos experiment workflows
├── outputs.tf        # Output values
└── README.md         # This file
```

## Notes

- **Shopping site, resume-app, postgres, redis** multi-resource YAML files are applied via `kubectl apply -f` (null_resource) so `---`-separated documents are applied correctly.
- **Resume** namespace uses an inline manifest in Terraform so the Deployment mounts the ConfigMap created from `resume.html`.
- **Ingress** requires the Minikube ingress addon; add hosts to `/etc/hosts` with `minikube ip` for local access.
