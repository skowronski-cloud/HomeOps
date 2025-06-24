resource "helm_release" "traefik" {
  # https://artifacthub.io/packages/helm/traefik/traefik
  repository = "https://traefik.github.io/charts/"
  chart      = "traefik"
  version    = var.ver_helm_traefik

  name      = "traefik"
  namespace = "traefik-system"
  set {
    name  = "logs.general.level"
    value = "DEBUG"
  }
  set {
    name  = "providers.kubernetesCRD.allowExternalNameServices"
    value = true
  }
  set {
    name  = "providers.kubernetesIngress.allowExternalNameServices"
    value = true
  }
  set_list {
    name  = "additionalArguments"
    value = ["--entryPoints.websecure.http.middlewares=traefik-system-forwardauth-authelia@kubernetescrd"]
  }

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
resource "random_password" "authelia_storage_enc_key" {
  length  = 128
  special = false
}
resource "helm_release" "authelia" {
  # https://artifacthub.io/packages/helm/authelia/authelia
  repository = "https://charts.authelia.com"
  chart      = "authelia"
  version    = var.ver_helm_authelia

  name      = "authelia"
  namespace = "traefik-system"

  values = [
    templatefile("${path.module}/template/authelia.yaml.tpl", {
      ingress_domain  = var.ingress_domain
      storage_enc_key = random_password.authelia_storage_enc_key.result
      ldap_url        = var.ldap_url
      ldap_basedn     = var.ldap_basedn
      ldap_filter     = var.ldap_filter
      ldap_user       = var.ldap_user
      ldap_pass       = var.ldap_pass
    })
  ]


  depends_on = [kubernetes_namespace.ns]
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
resource "helm_release" "echo_protected" {
  # https://artifacthub.io/packages/helm/ealenn/echo-server
  repository = "https://ealenn.github.io/charts"
  chart      = "echo-server"
  name       = "echo-server-protected"
  namespace  = "default"

  set {
    name  = "ingress.enabled"
    value = true
  }
  set {
    name  = "ingress.hosts[0].host"
    value = "protected-echo.${var.ingress_domain}"
  }
  set_list {
    name  = "ingress.hosts[0].paths"
    value = ["/"]
  }
  set {
    name  = "ingress.annotations.cert-manager\\.io/cluster-issuer"
    value = "yig-ca-issuer"
  }
  set {
    name  = "ingress.tls[0].secretName"
    value = "protected-echo-server-tls"
  }
  set_list {
    name = "ingress.tls[0].hosts"
    value = [
      "protected-echo.${var.ingress_domain}",
    ]
  }

  depends_on = [helm_release.metallb]
}
