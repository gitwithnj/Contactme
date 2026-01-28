# Chaos Mesh RBAC - ServiceAccount, ClusterRole, ClusterRoleBinding, namespace Roles

resource "null_resource" "chaos_mesh_rbac" {
  count = var.deploy_chaos_mesh ? 1 : 0

  triggers = {
    manifest = file("${local.manifests_path}/rbac.yaml")
  }
  provisioner "local-exec" {
    command = "kubectl apply -f ${local.manifests_path}/rbac.yaml"
  }
  depends_on = [helm_release.chaos_mesh[0]]
}
