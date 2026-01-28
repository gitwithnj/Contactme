# Resume App (dockerimagesloaded namespace): Deployment, Service, Ingress

resource "null_resource" "resume_app_deployment" {
  triggers = {
    manifest = file("${local.manifests_path}/resume-app-deployment.yaml")
  }
  provisioner "local-exec" {
    command = "kubectl apply -f ${local.manifests_path}/resume-app-deployment.yaml"
  }
  depends_on = [kubernetes_namespace.dockerimagesloaded]
}
