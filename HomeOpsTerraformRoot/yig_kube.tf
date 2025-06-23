module "yig_kube" {
  source = "./YigKube/"
  providers = {
    helm       = helm
    kubernetes = kubernetes
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
}

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
