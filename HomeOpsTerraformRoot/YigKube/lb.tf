resource "helm_release" "metallb" {
  # https://artifacthub.io/packages/helm/metallb/metallb
  repository = "https://metallb.github.io/metallb"
  chart      = "metallb"
  version    = var.ver_helm_metallb

  name      = "metallb"
  namespace = "metallb"

  depends_on = [kubernetes_namespace.ns]


}

resource "helm_release" "metallb_resources" {
  # https://artifacthub.io/packages/helm/deliveryhero/k8s-resources
  repository = "oci://ghcr.io/deliveryhero/helm-charts"
  chart      = "k8s-resources"
  version    = var.ver_helm_k8sr

  name      = "metallb-resources"
  namespace = "metallb"


  values = [templatefile("${path.module}/template/metallb_resources.yaml.tpl", {
    metallb_ipam           = var.metallb_ipam
  })]

  depends_on = [helm_release.metallb]
}

# TODO: consider Cillium and some IPAM
