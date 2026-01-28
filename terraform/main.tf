# Terraform configuration to deploy all applications to Minikube
# Consumes: namespaces, shopping-site, resume, resume-app, Chaos Mesh, RBAC, chaos workflows

locals {
  # Path to YAML manifests (parent directory)
  manifests_path = "${path.module}/.."
}

# Kubernetes provider - uses current kubeconfig (e.g. minikube)
provider "kubernetes" {
  config_path = var.kube_config_path != "" ? var.kube_config_path : null
  # When config_path is null, provider uses KUBECONFIG env or ~/.kube/config
}

# Helm provider for Chaos Mesh
provider "helm" {
  kubernetes {
    config_path = var.kube_config_path != "" ? var.kube_config_path : null
  }
}
