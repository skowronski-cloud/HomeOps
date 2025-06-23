resource "helm_release" "certmanager_ca" {
  # https://artifacthub.io/packages/helm/deliveryhero/k8s-resources
  repository = "oci://ghcr.io/deliveryhero/helm-charts/"
  chart      = "k8s-resources"
  version    = var.ver_helm_k8sr

  name      = "cert-manager-ca"
  namespace = "traefik-system"

  values = [
    templatefile("${path.module}/template/certmanager_ca.yaml.tpl", {
      yig_ca_crt = var.yig_ca_crt
      yig_ca_key = var.yig_ca_key
  })]

  depends_on = [helm_release.longhorn, kubernetes_namespace.ns, helm_release.certmanager]
}
resource "helm_release" "certmanager_crds" {
  # https://artifacthub.io/packages/helm/wiremind/cert-manager-crds?modal=install
  repository = "https://wiremind.github.io/wiremind-helm-charts"
  chart      = "cert-manager-crds"
  version    = var.ver_helm_certmanagercrds

  name      = "cert-manager-crds"
  namespace = "traefik-system"

  depends_on = [helm_release.longhorn, kubernetes_namespace.ns]
}

resource "helm_release" "certmanager" {
  # https://artifacthub.io/packages/helm/cert-manager/cert-manager
  repository = "https://charts.jetstack.io"
  chart      = "cert-manager"
  version    = var.ver_helm_certmanager

  name      = "cert-manager"
  namespace = "traefik-system"

  depends_on = [helm_release.longhorn, kubernetes_namespace.ns, helm_release.certmanager_crds]
}
