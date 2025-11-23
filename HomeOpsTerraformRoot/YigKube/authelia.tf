
resource "random_password" "authelia_storage_enc_key" {
  length  = 128
  special = false
}
resource "random_password" "oidc_session_enc_key" {
  length  = 128
  special = false
}
resource "random_password" "authelia_session_redis_pass" {
  length  = 128
  special = false
}
resource "random_password" "authelia_oidc_hmac_secret" {
  length  = 128
  special = false
}
resource "random_password" "authelia_idv_resetpass_jwt_hmac_key" {
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
  # TF Helm provider 3.x seems to regenrate manifest everytime, so we can't let chart use rand strings as they would rotate every time
  data = {
    "storage.encryption.key"                          = random_password.authelia_storage_enc_key.result
    "session.encryption.key"                          = random_password.oidc_session_enc_key.result
    "authentication.ldap.password.txt"                = var.ldap_pass
    "oidc-jwk.RS256.pem"                              = tls_private_key.authelia_idp.private_key_pem
    "notifier.smtp.password.txt"                      = var.common_smtp.password
    "duo.key"                                         = var.duo_authelia.secret_key
    "session.redis.password.txt"                      = random_password.authelia_session_redis_pass.result
    "session.redis.sentinel.password.txt"             = random_password.authelia_session_redis_pass.result
    "identity_providers.oidc.hmac.key"                = random_password.authelia_oidc_hmac_secret.result
    "identity_validation.reset_password.jwt.hmac.key" = random_password.authelia_idv_resetpass_jwt_hmac_key.result
  }
  type       = "Opaque"
  depends_on = [kubernetes_namespace.ns]
}

resource "tls_private_key" "authelia_idp" {
  algorithm = "RSA"
  rsa_bits  = 4096
}
locals {
  group_yig_ingress_users = "yig-ingress-users"
  group_yig_ingress_users_dn = "CN=${local.group_yig_ingress_users},${var.ldap_path}"
}
resource "ldap_entry" "group_yig_ingress_users" {
  # https://registry.terraform.io/providers/l-with/ldap/latest/docs/resources/entry
  dn = local.group_yig_ingress_users_dn
  data_json = jsonencode({
    description = ["TF Managed group for Yig Ingress users"]
    objectClass = ["top", "group"]
    name        = [local.group_yig_ingress_users]
    cn        = [local.group_yig_ingress_users]
    member      = concat([for user in var.vm_users : ldap_entry.vm_users_objects[user.username].dn],["CN=daniel,${var.ldap_path}"])
  })
  ignore_attributes = [
    "distinguishedName", "groupType", "instanceType", "objectCategory", "objectGUID", "objectSid", "sAMAccountName", 
    "sAMAccountType", "uSNChanged", "uSNCreated", "whenChanged", "whenCreated",
  ]
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

      ingress_base_group  = var.ingress_base_group   # FIXME: import and manage from TF
      ingress_admin_group = var.ingress_admin_group  # FIXME: import and manage from TF

      smtp_host = var.common_smtp.server
      smtp_port = var.common_smtp.port
      smtp_user = var.common_smtp.user

      duo_api_hostname    = var.duo_authelia.api_hostname
      duo_integration_key = var.duo_authelia.integration_key

      xasc                  = local.highlyAvailableServiceConfig
      metrics_label_release = helm_release.promstack.name

      group_yig_vm_users = local.group_yig_vm_users
    })
  ]


  depends_on = [kubernetes_namespace.ns, kubernetes_secret.authelia_secrets]
}
