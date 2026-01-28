# Chaos Engineering Workflows - apply all workflow YAMLs from chaos-workflows/

resource "null_resource" "chaos_workflows" {
  for_each = var.deploy_chaos_workflows ? toset([
    "pod-kill-workflow.yaml",
    "pod-failure-workflow.yaml",
    "network-delay-workflow.yaml",
    "network-partition-workflow.yaml",
    "network-loss-workflow.yaml",
    "network-bandwidth-workflow.yaml",
    "cpu-stress-workflow.yaml",
    "memory-stress-workflow.yaml",
    "io-stress-workflow.yaml",
    "scheduled-pod-kill.yaml",
  ]) : toset([])

  triggers = {
    manifest = file("${local.manifests_path}/chaos-workflows/${each.key}")
  }
  provisioner "local-exec" {
    command = "kubectl apply -f ${local.manifests_path}/chaos-workflows/${each.key}"
  }
  depends_on = [
    null_resource.chaos_mesh_rbac,
    null_resource.resume_app_deployment,
  ]
}
