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
  set = [
    {
      name  = "service.type"
      value = "LoadBalancer"
    },
    {
      name  = "persistence.enabled"
      value = true
    },
    {
      name  = "mosquitto.persistence.enabled"
      value = true # BUG
    },
    {
      name  = "mosquitto.persistence.path"
      value = "/mosquitto/data/"
    },
    {
      name  = "replicaCount"
      value = 1 # var.replicas # TODO: test this, maybe use other chart
    }
  ]
  set_list = [
    {
      name  = "mosquitto.persistence.accessModes"
      value = ["ReadWriteMany"]
    }

  ]


  depends_on = [helm_release.longhorn, kubernetes_namespace.ns]
}


