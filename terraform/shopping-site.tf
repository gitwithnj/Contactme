# Shopping Site: ConfigMap, Secret, PostgreSQL, Redis, Backend API, Ingress

resource "kubernetes_config_map" "shopping_config" {
  metadata {
    name      = "shopping-config"
    namespace = kubernetes_namespace.shopping_site.metadata[0].name
  }
  data = {
    REACT_APP_API_URL = "http://shopping-api-service:8080"
    API_PORT          = "8080"
    CACHE_HOST        = "redis-service"
    CACHE_PORT        = "6379"
    DB_HOST           = "postgres-service"
    DB_PORT           = "5432"
    DB_NAME           = "shoppingdb"
  }
}

resource "kubernetes_secret" "shopping_secrets" {
  metadata {
    name      = "shopping-secrets"
    namespace = kubernetes_namespace.shopping_site.metadata[0].name
  }
  type = "Opaque"
  data = {
    DB_USER         = base64encode("shopping_user")
    DB_PASSWORD     = base64encode("shopping_password_123")
    JWT_SECRET      = base64encode("your-super-secret-jwt-key-change-in-production")
    SESSION_SECRET  = base64encode("your-session-secret-key")
  }
}

# Apply multi-resource YAML files via kubectl (handles --- separated docs)
resource "null_resource" "shopping_postgres" {
  triggers = {
    manifest = file("${local.manifests_path}/postgres-deployment.yaml")
  }
  provisioner "local-exec" {
    command = "kubectl apply -f ${local.manifests_path}/postgres-deployment.yaml"
  }
  depends_on = [
    kubernetes_namespace.shopping_site,
    kubernetes_config_map.shopping_config,
    kubernetes_secret.shopping_secrets,
  ]
}

resource "null_resource" "shopping_redis" {
  triggers = {
    manifest = file("${local.manifests_path}/redis-deployment.yaml")
  }
  provisioner "local-exec" {
    command = "kubectl apply -f ${local.manifests_path}/redis-deployment.yaml"
  }
  depends_on = [kubernetes_namespace.shopping_site]
}

resource "null_resource" "shopping_backend" {
  triggers = {
    manifest = file("${local.manifests_path}/backend-deployment.yaml")
  }
  provisioner "local-exec" {
    command = "kubectl apply -f ${local.manifests_path}/backend-deployment.yaml"
  }
  depends_on = [
    null_resource.shopping_postgres,
    null_resource.shopping_redis,
  ]
}

resource "null_resource" "shopping_ingress" {
  triggers = {
    manifest = file("${local.manifests_path}/ingress.yaml")
  }
  provisioner "local-exec" {
    command = "kubectl apply -f ${local.manifests_path}/ingress.yaml"
  }
  depends_on = [null_resource.shopping_backend]
}
