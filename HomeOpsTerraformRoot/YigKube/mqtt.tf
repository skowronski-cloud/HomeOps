resource "helm_release" "mosquitto" {
  # https://artifacthub.io/packages/helm/kfirfer/mosquitto
  repository = "https://kfirfer.github.io/charts/"
  chart      = "mosquitto"
  version    = var.ver_helm_mosquitto

  name      = "mosquitto"
  namespace = "mosquitto"

  values = [templatefile("${path.module}/template/mosquitto.yaml.tpl", {
    mqtt_accounts = var.mqtt_accounts
  })]
  set {
    name  = "service.type"
    value = "LoadBalancer"
  }

  set {
    name  = "persistence.enabled"
    value = true
  }
  set {
    name  = "mosquitto.persistence.enabled"
    value = true
  }
  set {
    name  = "mosquitto.persistence.path"
    value = "/mosquitto/data/"
  }


  depends_on = [helm_release.longhorn, kubernetes_namespace.ns]
}


