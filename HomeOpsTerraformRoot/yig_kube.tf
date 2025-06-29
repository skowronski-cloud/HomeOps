module "yig_kube" {
  source = "./YigKube/"
  providers = {
    helm       = helm
    kubernetes = kubernetes
    tls        = tls
    # TODO: Cloudflare for DNS?
  }
  address_ingress_main      = var.yig_address_ingress_main
  address_ingress_matter    = var.yig_address_ingress_matter
  address_ingress_mqtt      = var.yig_address_ingress_mqtt
  top_domain                = var.yig_top_domain
  ingress_domain            = var.yig_ingress_domain
  mqtt_accounts             = var.yig_mqtt_accounts
  yig_ca_crt                = var.yig_ca_crt
  yig_ca_key                = var.yig_ca_key
  host_interface_for_matter = var.yig_host_interface_for_matter
  ldap_basedn               = var.yig_ldap_basedn
  ldap_filter               = var.yig_ldap_filter
  ldap_url                  = var.yig_ldap_url
  ldap_user                 = var.yig_ldap_user
  ldap_pass                 = var.yig_ldap_pass

  ingress_base_group  = var.yig_ingress_base_group
  ingress_admin_group = var.yig_ingress_admin_group

  tool_email   = var.tool_email
  duo_authelia = var.yig_duo_authelia

  bb_targets = var.yig_bb_targets
}

# FIXME: consolidate variables into logically connected objects

variable "yig_address_ingress_main" {
  type        = string
  description = "CIDR for main ingress, to be read from secrets"
}
variable "yig_address_ingress_mqtt" {
  type        = string
  description = "CIDR for MQTT LB, to be read from secrets"
}
variable "yig_address_ingress_matter" {
  type        = string
  description = "CIDR for Matter LB, to be read from secrets"
}
variable "yig_top_domain" {
  type        = string
  description = "FQDN of parent domain, to be read from secrets"
}
variable "yig_ingress_domain" {
  type        = string
  description = "FQDN of ingress domain (usually yig.$yig_top_domain), to be read from secrets"
}
variable "yig_mqtt_accounts" {
  type = map(object({
    user = string
    pass = string
    hash = string       # generated manually using mosquitto_passwd
    acl  = list(string) # extra ALCs
  }))
  description = "map of MQTT accounts for HA, to be read from secrets"
}
variable "yig_ca_crt" {
  type        = string
  description = "dedicated CA for Yig runtime (e.g. CertManager) - Certificate, to be read from secrets"
  # TODO: this should be also CA for k8s
}
variable "yig_ca_key" {
  type        = string
  description = "dedicated CA for Yig runtime (e.g. CertManager) - Secret Key, to be read from secrets"
}
variable "yig_host_interface_for_matter" {
  type        = string
  description = "interface on host OS to be passed into Matter controller, to be read from secrets"
}
variable "yig_ldap_url" {
  type        = string
  description = "url for ldap connection for authelia, to be read from secrets"
  default     = "ldap://..."
}
variable "yig_ldap_basedn" {
  type        = string
  description = "base DN  for authelia, to be read from secrets"
  default     = "DC=example,DC=com"
}
variable "yig_ldap_filter" {
  type        = string
  description = "filter for users for authelia, to be read from secrets"
  default     = "(&({username_attribute}={input})(objectClass=person)(memberOf=CN=yig-ingress-users,CN=Users,DC=example,DC=com))"

}

variable "yig_ldap_user" {
  type        = string
  description = "service account in LDAP for authelia, to be read from secrets"
}
variable "yig_ldap_pass" {
  type        = string
  description = "service account password in LDAP for authelia, to be read from secrets"
}

variable "yig_ingress_base_group" {
  type        = string
  description = "base group for users in authelia, to be read from secrets"
  default     = "yig-ingress-users"
}
variable "yig_ingress_admin_group" {
  type        = string
  description = "admin group for users in authelia, to be read from secrets"
  default     = "yig-ingress-adminusers"
}

variable "yig_duo_authelia" {
  type = object({
    api_hostname    = string
    integration_key = string
    secret_key      = string
  })
  description = "values for Duo integration with Authelia, to be read from secrets"
}

variable "yig_bb_targets" {
  type = map(object({
    url      = string
    interval = string
    module   = string
  }))
  description = "targets for BlackBox exporter, to be read from secrets"
}
