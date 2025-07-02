resource "helm_release" "matter" {
  # https://artifacthub.io/packages/helm/charts-derwitt-dev/home-assistant-matter-server
  repository = "https://charts.derwitt.dev"
  chart      = "home-assistant-matter-server"
  version    = var.ver_helm_matter

  name      = "home-assistant-matter-server"
  namespace = "home-assistant"
  set = [
    {
      name  = "service.type"
      value = "LoadBalancer"
    },
    {
      name  = "networkInterface"
      value = var.host_interface_for_matter
    }
  ]
  depends_on = [helm_release.longhorn, kubernetes_namespace.ns]
}
