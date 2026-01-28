# Resume (resume namespace): ConfigMap from resume.html, Deployment, Service, Ingress
# Note: resume.yaml expects a ConfigMap "resume-html" created from resume.html

resource "kubernetes_config_map" "resume_html" {
  metadata {
    name      = "resume-html"
    namespace = kubernetes_namespace.resume.metadata[0].name
  }
  data = {
    "index.html" = file("${local.manifests_path}/resume.html")
  }
}

resource "null_resource" "resume_deployment" {
  triggers = {
    manifest = file("${local.manifests_path}/resume.yaml")
    # Re-apply when resume.html changes (resume.yaml has 3 docs: namespace, deployment, service, ingress)
    config = kubernetes_config_map.resume_html.data["index.html"]
  }
  provisioner "local-exec" {
    command = <<-EOT
      kubectl apply -f - <<YAML
apiVersion: apps/v1
kind: Deployment
metadata:
  name: resume
  namespace: resume
  labels:
    app: resume
spec:
  replicas: 2
  selector:
    matchLabels:
      app: resume
  template:
    metadata:
      labels:
        app: resume
    spec:
      containers:
      - name: nginx
        image: nginx:alpine
        ports:
        - name: http
          containerPort: 80
          protocol: TCP
        volumeMounts:
        - name: resume-content
          mountPath: /usr/share/nginx/html
        resources:
          requests:
            memory: "64Mi"
            cpu: "50m"
          limits:
            memory: "128Mi"
            cpu: "100m"
        livenessProbe:
          httpGet:
            path: /
            port: 80
          initialDelaySeconds: 10
          periodSeconds: 10
        readinessProbe:
          httpGet:
            path: /
            port: 80
          initialDelaySeconds: 5
          periodSeconds: 5
      volumes:
      - name: resume-content
        configMap:
          name: resume-html
---
apiVersion: v1
kind: Service
metadata:
  name: resume-service
  namespace: resume
  labels:
    app: resume
spec:
  type: ClusterIP
  ports:
  - port: 80
    targetPort: 80
    protocol: TCP
    name: http
  selector:
    app: resume
---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: resume-ingress
  namespace: resume
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  ingressClassName: nginx
  rules:
  - host: resume.local
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: resume-service
            port:
              number: 80
YAML
    EOT
  }
  depends_on = [
    kubernetes_namespace.resume,
    kubernetes_config_map.resume_html,
  ]
}
