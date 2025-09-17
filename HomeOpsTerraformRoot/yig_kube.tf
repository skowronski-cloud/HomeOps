module "yig_kube" {
  source = "./YigKube/"
  providers = {
    helm       = helm
    kubernetes = kubernetes
    tls        = tls
    restapi    = restapi
    # TODO: Cloudflare for DNS?
  }
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

  common_smtp  = var.common_smtp
  duo_authelia = var.yig_duo_authelia

  bb_targets    = var.yig_bb_targets
  flux_sops_gpg = var.flux_sops_gpg
  flux_git_ssh  = var.flux_git_ssh

  synology_stor_acct    = var.yig_synology_stor_acct
  synology_velero_minio = var.yig_synology_velero_minio

  mikrotik_monitoring_account   = module.core.monitoring_prometheus_auth
  mikrotik_monitoring_router_ip = var.ros_hex.addr

  metallb_ipam = var.metallb_ipam
}

# FIXME: consolidate variables into logically connected objects


variable "metallb_ipam" {
  type = map(object({
    name      = string
    addresses = list(string)
    # TODO: add creation of DNS records in Cloudflare or ROS
    namespaces = optional(list(string))
    svcSelectors = optional(list(object({
      key      = string
      operator = string
      values   = list(string)
    })))
  }))
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
    emqx_acl = optional(list(object({
      action     = string
      permission = string
      topic      = string
      retain     = optional(string, "all")
      qos        = optional(list(number), [0, 1, 2])
    })), [])
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
variable "flux_sops_gpg" {
  type = object({
    public  = string
    private = string
  })
  description = "base64-encoded GPG keys for Flux SOPS integration, to be read from secrets"
}

variable "flux_git_ssh" {
  type = object({
    key = string
  })
  description = "base64-encoded SSH keys for Flux SOPS integration, to be read from secrets"
}

variable "yig_synology_stor_acct" {
  type = object({
    user = string
    pass = string
    host = string
    path = string
  })
  description = "CIFS credentials for Synology NAS backup storage - used by Longhorn for backups"
}
variable "yig_synology_velero_minio" {
  type = object({
    host = string
    user = string
    pass = string
    port = number
  })
  description = "Synology MinIO for Velero backups"
}
