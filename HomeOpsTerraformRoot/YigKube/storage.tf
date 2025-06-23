
resource "helm_release" "longhorn" {
  # https://artifacthub.io/packages/helm/longhorn/longhorn
  chart      = "longhorn"
  repository = "https://charts.longhorn.io/"
  version    = var.ver_helm_longhorn

  name      = "longhorn"
  namespace = "longhorn-system"

  set {
    name  = "persistence.defaultClassReplicaCount"
    value = 1
  }
  set {
    name  = "defaultSettings.defaultDataPath"
    value = "/data/longhorn"
  }

  depends_on = [kubernetes_namespace.ns]
}
