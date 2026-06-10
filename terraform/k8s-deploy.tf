resource "null_resource" "k8s_deploy" {

  triggers = {
    always_run = timestamp()
  }

  provisioner "local-exec" {
    command = "kubectl apply -f ${path.module}/../k8s/configmap/"
  }

  provisioner "local-exec" {
    command = "kubectl apply -f ${path.module}/../k8s/secret/"
  }

  provisioner "local-exec" {
    command = "kubectl apply -f ${path.module}/../k8s/mongodb/"
  }

  provisioner "local-exec" {
    command = "kubectl apply -f ${path.module}/../k8s/backend/"
  }

  provisioner "local-exec" {
    command = "kubectl apply -f ${path.module}/../k8s/frontend/"
  }

  provisioner "local-exec" {
    command = "kubectl apply -f ${path.module}/../k8s/ingress/"
  }

  provisioner "local-exec" {
    command = "kubectl get pods -n default"
  }
}
