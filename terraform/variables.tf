variable "kube_config_path" {
  description = "Path to kubeconfig file. Leave empty to use default (KUBECONFIG env or ~/.kube/config)"
  type        = string
  default     = ""
}

variable "deploy_chaos_mesh" {
  description = "Whether to deploy Chaos Mesh via Helm"
  type        = bool
  default     = true
}

variable "deploy_chaos_workflows" {
  description = "Whether to deploy chaos engineering workflows"
  type        = bool
  default     = true
}

variable "chaos_mesh_helm_chart_version" {
  description = "Chaos Mesh Helm chart version"
  type        = string
  default     = "2.8.1"
}

variable "chaos_daemon_runtime" {
  description = "Container runtime for Chaos Mesh daemon (containerd or docker)"
  type        = string
  default     = "containerd"
}

variable "chaos_daemon_socket_path" {
  description = "Socket path for container runtime"
  type        = string
  default     = "/run/containerd/containerd.sock"
}

variable "resume_app_image_pull_policy" {
  description = "Image pull policy for resume-app (Never for Minikube with pre-loaded images)"
  type        = string
  default     = "Never"
}
