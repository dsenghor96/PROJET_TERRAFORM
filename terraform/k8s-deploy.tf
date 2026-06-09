# Déploiement de l'app sur le cluster kind via kubectl

resource "null_resource" "k8s_deploy" {

  triggers = {
    always_run = timestamp()
  }

  # 1. Configmap et secret
  provisioner "local-exec" {
    command = "kubectl apply -f ${path.module}/../k8s/configmap/"
  }

  provisioner "local-exec" {
    command = "kubectl apply -f ${path.module}/../k8s/secret/"
  }

  # 2. MongoDB
  provisioner "local-exec" {
    command = "kubectl apply -f ${path.module}/../k8s/mongodb/"
  }

  # 3. Attendre MongoDB
  provisioner "local-exec" {
    command = "kubectl rollout status statefulset/mongodb -n default --timeout=120s"
  }

  # 4. Backend et frontend
  provisioner "local-exec" {
    command = "kubectl apply -f ${path.module}/../k8s/backend/"
  }

  provisioner "local-exec" {
    command = "kubectl apply -f ${path.module}/../k8s/frontend/"
  }

  # 5. Ingress uniquement
  provisioner "local-exec" {
    command = "kubectl apply -f ${path.module}/../k8s/ingress/"
  }

  # 6. Vérifier
  provisioner "local-exec" {
    command = "kubectl get pods -n default"
  }
}
