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
    name = "additionalArguments"
    value = [
      "--entryPoints.websecure.http.middlewares=traefik-system-forwardauth-authelia@kubernetescrd",
      #"--entryPoints.websecure.forwardedHeaders.trustedIPs=10.244.0.0/16",
      "--serversTransport.rootCAs=/etc/pki/tls/certs/ca.crt"
    ]
  }

  set {
    name  = "experimental.plugins.traefikoidc.moduleName"
    value = "github.com/lukaszraczylo/traefikoidc"
  }
  set {
    name  = "experimental.plugins.traefikoidc.version"
    value = "v0.6.2-beta10" # FIXME - version variable
  }
  set {
    name  = "volumes[0].name"
    value = "ca-crt"
  }
  set {
    name  = "volumes[0].mountPath"
    value = "/etc/pki/tls/certs" # https://go.dev/src/crypto/x509/root_linux.go - purposefully other dir than OS-default
  }
  set {
    name  = "volumes[0].type"
    value = "secret"
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
resource "random_password" "oidc_session_enc_key" {
  length  = 128
  special = false
}
resource "random_password" "oidc_grafana_client_secret" {
  # TODO: this should be generated on runtime and not managed from here
  length  = 32
  special = false
}
resource "random_password" "oidc_grafana_client_id" {
  length  = 32
  special = false
}
resource "kubernetes_secret" "oidc_grafana_client" {
  for_each = { # TODO: this is clear sign that some Secret Operator is required!
    "traefik-system" : {},
    "monitoring-system" : {}
  }
  metadata {
    namespace = each.key
    name      = "oidc-grafana-client"
  }
  data = {
    "client-id"     = random_password.oidc_grafana_client_id.result
    "client-secret" = random_password.oidc_grafana_client_secret.result
    "cookie-secret" = random_password.oidc_session_enc_key.result
  }
  type       = "Opaque"
  depends_on = [kubernetes_namespace.ns]
}


resource "kubernetes_secret" "authelia_secrets" {
  metadata {
    namespace = "traefik-system"
    name      = "authelia-secrets"
  }
  data = {
    "storage.encryption.key"           = random_password.authelia_storage_enc_key.result
    "session.encryption.key"           = random_password.oidc_session_enc_key.result
    "authentication.ldap.password.txt" = var.ldap_pass
    "oidc-jwk.RS256.pem"               = tls_private_key.authelia_idp.private_key_pem
    "notifier.smtp.password.txt"       = var.tool_email.password
    "duo.key"                          = var.duo_authelia.secret_key
  }
  type       = "Opaque"
  depends_on = [kubernetes_namespace.ns]
}

resource "tls_private_key" "authelia_idp" {
  algorithm = "RSA"
  rsa_bits  = 4096
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
      ingress_domain = var.ingress_domain
      ldap_url       = var.ldap_url
      ldap_basedn    = var.ldap_basedn
      ldap_filter    = var.ldap_filter
      ldap_user      = var.ldap_user

      oidc_grafana_client_id = random_password.oidc_grafana_client_id.result

      oidc_public_key = tls_private_key.authelia_idp.public_key_pem

      ingress_base_group  = var.ingress_base_group
      ingress_admin_group = var.ingress_admin_group

      smtp_host = var.tool_email.server
      smtp_port = var.tool_email.port
      smtp_user = var.tool_email.user

      duo_api_hostname    = var.duo_authelia.api_hostname
      duo_integration_key = var.duo_authelia.integration_key
    })
  ]


  depends_on = [kubernetes_namespace.ns, kubernetes_secret.authelia_secrets]
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
