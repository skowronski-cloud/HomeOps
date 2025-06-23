resource "helm_release" "traefik" {
  # https://artifacthub.io/packages/helm/traefik/traefik
  repository = "https://traefik.github.io/charts/"
  chart      = "traefik"
  version    = var.ver_helm_traefik

  name      = "traefik"
  namespace = "traefik-system"

  depends_on = [kubernetes_namespace.ns]
}
resource "helm_release" "traefik_resources" {
  # https://artifacthub.io/packages/helm/deliveryhero/k8s-resources
  repository = "oci://ghcr.io/deliveryhero/helm-charts"
  chart      = "k8s-resources"
  version    = var.ver_helm_k8sr

  name      = "traefik-resources"
  namespace = "traefik-system"

  values = [
    templatefile("${path.module}/template/traefik_resources.yaml.tpl", {
      ingress_domain = var.ingress_domain
    })
  ]

  depends_on = [helm_release.traefik]
}
