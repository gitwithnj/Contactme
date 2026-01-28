# Namespaces - created first so all other resources can reference them

resource "kubernetes_namespace" "shopping_site" {
  metadata {
    name = "shopping-site"
    labels = {
      name = "shopping-site"
    }
  }
}

resource "kubernetes_namespace" "dockerimagesloaded" {
  metadata {
    name = "dockerimagesloaded"
    labels = {
      name = "dockerimagesloaded"
    }
  }
}

resource "kubernetes_namespace" "resume" {
  metadata {
    name = "resume"
    labels = {
      name = "resume"
    }
  }
}

resource "kubernetes_namespace" "chaos_mesh" {
  count = var.deploy_chaos_mesh ? 1 : 0

  metadata {
    name = "chaos-mesh"
  }
}
