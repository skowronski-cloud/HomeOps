
resource "helm_release" "longhorn" {
  # https://artifacthub.io/packages/helm/longhorn/longhorn
  chart      = "longhorn"
  repository = "https://charts.longhorn.io/"
  version    = var.ver_helm_longhorn

  name      = "longhorn"
  namespace = "longhorn-system"

  # TODO: default backup store - https://artifacthub.io/packages/helm/longhorn/longhorn#other-settings

  values = [templatefile("${path.module}/template/longhorn.yaml.tpl", {
    ingress_domain               = var.ingress_domain,
    workers_count                = var.workers_count,
    highlyAvailableServiceConfig = local.highlyAvailableServiceConfig
    metrics_label_release        = "kube-prometheus-stack" # fixed to avoid circular dependency with prometheus stack
  })]

  depends_on = [kubernetes_namespace.ns]
}
