# Chaos Mesh - deployed via Helm

resource "helm_release" "chaos_mesh" {
  count = var.deploy_chaos_mesh ? 1 : 0

  repository = "https://charts.chaos-mesh.org"
  chart      = "chaos-mesh"
  name       = "chaos-mesh"
  namespace  = kubernetes_namespace.chaos_mesh[0].metadata[0].name
  version    = var.chaos_mesh_helm_chart_version

  set {
    name  = "chaosDaemon.runtime"
    value = var.chaos_daemon_runtime
  }
  set {
    name  = "chaosDaemon.socketPath"
    value = var.chaos_daemon_socket_path
  }

  depends_on = [kubernetes_namespace.chaos_mesh]
}
