# Nginx Ingress Controller via Helm
resource "helm_release" "nginx_ingress" {
  name             = "nginx-ingress"
  repository       = "https://kubernetes.github.io/ingress-nginx"
  chart            = "ingress-nginx"
  namespace        = "ingress-nginx"
  create_namespace = true
  version          = "4.10.1"

  set {
    name  = "controller.service.type"
    value = "LoadBalancer"
  }

  set {
    name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-type"
    value = "nlb"
  }

  depends_on = [
    aws_eks_node_group.portfolio_nodes,
    null_resource.gp2_default_storageclass
  ]
}

# Output - hostname du LoadBalancer Nginx
output "nginx_ingress_hostname" {
  description = "Hostname du LoadBalancer Nginx Ingress"
  value       = helm_release.nginx_ingress.status
}
