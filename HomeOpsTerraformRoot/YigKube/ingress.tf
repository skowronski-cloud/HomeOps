resource "kubernetes_secret" "ca_crt" {
  for_each = {
    "traefik-system" : {},
    "monitoring-system" : {}
  }
  metadata {
    name      = "ca-crt"
    namespace = each.key
  }
  type = "Opaque"

  binary_data = {
    "ca.crt" = var.yig_ca_crt # it's already base64
  }

  depends_on = [kubernetes_namespace.ns]
}
resource "helm_release" "traefik" {
  # https://artifacthub.io/packages/helm/traefik/traefik
  repository = "https://traefik.github.io/charts/"
  chart      = "traefik"
  version    = var.ver_helm_traefik

  name      = "traefik"
  namespace = "traefik-system"
  set = [
    {
      name  = "logs.general.level"
      value = "DEBUG"
    },
    {
      name  = "providers.kubernetesCRD.allowExternalNameServices"
      value = true
    },
    {
      name  = "providers.kubernetesIngress.allowExternalNameServices"
      value = true
    },
    {
      name  = "volumes[0].mountPath"
      value = "/etc/pki/tls/certs" # https://go.dev/src/crypto/x509/root_linux.go - purposefully other dir than OS-default
    },
    {
      name  = "volumes[0].type"
      value = "secret"
    },
    {
      name  = "volumes[0].name"
      value = "ca-crt"
    }
  ]
  set_list = [
    {
      name = "additionalArguments"
      value = [
        "--entryPoints.websecure.http.middlewares=traefik-system-forwardauth-authelia@kubernetescrd",
        "--serversTransport.rootCAs=/etc/pki/tls/certs/ca.crt"
      ]
    }
  ]

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
resource "helm_release" "echo" {
  # https://artifacthub.io/packages/helm/ealenn/echo-server
  repository = "https://ealenn.github.io/charts"
  chart      = "echo-server"
  name       = "echo-server"
  namespace  = "default"





  set = [
    {
      name  = "ingress.enabled"
      value = true
    },
    {
      name  = "ingress.hosts[0].host"
      value = "echo.${var.ingress_domain}"
    },
    {
      name  = "ingress.annotations.cert-manager\\.io/cluster-issuer"
      value = "yig-ca-issuer"
    },
    {
      name  = "ingress.tls[0].secretName"
      value = "echo-server-tls"
    },
    {
      name  = "ingress.hosts[1].host"
      value = "echo.${var.top_domain}"
    }
  ]
  set_list = [{
    name  = "ingress.hosts[0].paths"
    value = ["/"]
    }
    , {
      name  = "ingress.hosts[1].paths"
      value = ["/"]
    }
    , {
      name = "ingress.tls[0].hosts"
      value = [
        "echo.${var.ingress_domain}",
        "echo.${var.top_domain}"
      ]
    }
  ]

  depends_on = [helm_release.metallb]
}
