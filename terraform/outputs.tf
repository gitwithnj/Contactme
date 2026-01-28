output "namespaces" {
  description = "Created namespaces"
  value = {
    shopping_site       = kubernetes_namespace.shopping_site.metadata[0].name
    dockerimagesloaded  = kubernetes_namespace.dockerimagesloaded.metadata[0].name
    resume              = kubernetes_namespace.resume.metadata[0].name
    chaos_mesh          = var.deploy_chaos_mesh ? kubernetes_namespace.chaos_mesh[0].metadata[0].name : null
  }
}

output "shopping_site_ingress_host" {
  description = "Shopping site ingress host (add to /etc/hosts with minikube ip)"
  value       = "shopping.local"
}

output "resume_app_ingress_host" {
  description = "Resume app ingress host (add to /etc/hosts with minikube ip)"
  value       = "resume-app.local"
}

output "resume_ingress_host" {
  description = "Resume ingress host (add to /etc/hosts with minikube ip)"
  value       = "resume.local"
}

output "access_commands" {
  description = "Useful kubectl commands for accessing deployed applications"
  value = <<-EOT
    # Port forward resume-app
    kubectl port-forward -n dockerimagesloaded svc/resume-app-service 8083:80
    # Then open http://localhost:8083

    # Port forward shopping API
    kubectl port-forward -n shopping-site svc/shopping-api-service 8080:8080

    # Port forward Chaos Dashboard
    kubectl port-forward -n chaos-mesh svc/chaos-dashboard 2333:2333
    # Then open http://localhost:2333

    # Add ingress hosts (replace MINIKUBE_IP with output of: minikube ip)
    echo "MINIKUBE_IP resume-app.local resume.local shopping.local" | sudo tee -a /etc/hosts
  EOT
}
