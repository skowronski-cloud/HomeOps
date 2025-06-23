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
    address_ingress_mqtt   = var.address_ingress_mqtt
    address_ingress_matter = var.address_ingress_matter
    address_ingress_main   = var.address_ingress_main
  })]

  depends_on = [helm_release.metallb]
}
resource "helm_release" "echo" {
  # https://artifacthub.io/packages/helm/ealenn/echo-server
  repository = "https://ealenn.github.io/charts"
  chart      = "echo-server"
  name       = "echo-server"
  namespace  = "default"

  set {
    name  = "ingress.enabled"
    value = true
  }
  set {
    name  = "ingress.hosts[0].host"
    value = "echo.${var.ingress_domain}"
  }
  set_list {
    name  = "ingress.hosts[0].paths"
    value = ["/"]
  }
  set {
    name  = "ingress.hosts[1].host"
    value = "echo.${var.top_domain}"
  }
  set_list {
    name  = "ingress.hosts[1].paths"
    value = ["/"]
  }
  set {
    name  = "ingress.annotations.cert-manager\\.io/cluster-issuer"
    value = "yig-ca-issuer"
  }
  set {
    name  = "ingress.tls[0].secretName"
    value = "echo-server-tls"
  }
  set_list {
    name = "ingress.tls[0].hosts"
    value = [
      "echo.${var.ingress_domain}",
      "echo.${var.top_domain}"
    ]
  }

  depends_on = [helm_release.metallb]
}
