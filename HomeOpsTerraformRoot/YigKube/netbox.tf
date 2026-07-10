resource "random_password" "netbox_admin_password" {
  length  = 64
  special = false
}
resource "random_password" "netbox_valkey_password" {
  length  = 10
  special = false
}
resource "random_password" "netbox_postgres_password" {
  length  = 10
  special = false
}
resource "random_uuid" "netbox_admin_token" {

}
resource "kubernetes_secret" "netbox_secrets" {
  metadata {
    name      = "netbox-secrets"
    namespace = "netbox"
  }
  data = {
    "ldap_bind_password" = var.ldap_pass
    "username"           = "admin"
    "password"           = random_password.netbox_admin_password.result
    "email"              = "admin@${var.top_domain}"
    "api_token"          = base64encode(random_uuid.netbox_admin_token.result)
  }
}
resource "helm_release" "netbox" {
  # https://artifacthub.io/packages/helm/netbox/netbox
  repository = "oci://ghcr.io/netbox-community/netbox-chart/"
  chart      = "netbox"
  version    = var.ver_helm_netbox

  name       = "netbox"
  namespace  = "netbox"
  description = "NetBox for IPAM and DCIM AHID=netbox/netbox"

  values = [templatefile("${path.module}/template/netbox_values.yaml.tpl", {
    ver_docker_netbox_custom = var.ver_docker_netbox_custom
    ldap_url                 = var.ldap_url
    ldap_basedn              = var.ldap_basedn
    ldap_filter              = var.ldap_filter
    ldap_user                = var.ldap_user
    admin_group              = var.ingress_admin_group
    ingress_domain           = var.ingress_domain
    valkey_password = nonsensitive(random_password.netbox_valkey_password.result)
    postgres_password = nonsensitive(random_password.netbox_postgres_password.result)
  })]


  depends_on = [kubernetes_namespace.ns, kubernetes_secret.netbox_secrets]

  timeout = 1800 # 30mins, first start of netbox takes ages
}