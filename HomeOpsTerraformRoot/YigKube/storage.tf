
resource "helm_release" "longhorn" {
  # https://artifacthub.io/packages/helm/longhorn/longhorn
  chart      = "longhorn"
  repository = "https://charts.longhorn.io/"
  version    = var.ver_helm_longhorn

  name      = "longhorn"
  namespace = "longhorn-system"

  # TODO: default backup store - https://artifacthub.io/packages/helm/longhorn/longhorn#other-settings

  set = [
    {
      name  = "persistence.defaultClassReplicaCount"
      value = var.replicas
    },
    {
      name  = "defaultSettings.defaultDataPath"
      value = "/data/longhorn"
    },

    {
      name  = "ingress.enabled"
      value = true
    },
    {
      name  = "ingress.host"
      value = "longhorn.${var.ingress_domain}"
    },
    {
      name = "csi.attacherReplicaCount"
      value = var.replicas
    },
    {
      name = "csi.provisionerReplicaCount"
      value = var.replicas
    },
    {
      name = "csi.resizerReplicaCount"
      value = var.replicas
    },

    {
      name = "csi.snapshotterReplicaCount"
      value = var.replicas
    }

  ]

  depends_on = [kubernetes_namespace.ns]
}
