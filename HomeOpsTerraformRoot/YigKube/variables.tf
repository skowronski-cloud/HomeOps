variable "address_ingress_main" {
  type    = string
  default = "127.0.1.1/32"
}
variable "address_ingress_matter" {
  type    = string
  default = "127.0.1.2/32"
}
variable "address_ingress_mqtt" {
  type    = string
  default = "127.0.1.3/32"
}

variable "top_domain" {
  type = string
}
variable "ingress_domain" {
  type = string
}

variable "mqtt_accounts" {
  default = {
    "topic" = {
      "user" = "username"
      "pass" = "password"
      "acl"  = []
    }
  }
}

variable "yig_ca_crt" {
  type = string
}
variable "yig_ca_key" {
  type = string
}

variable "ha_postgres_instance_name" {
  type    = string
  default = "ha-recorder"
}
variable "host_interface_for_matter" {
  type    = string
  default = "eth0"
}

variable "ldap_url" {
  type = string
}
variable "ldap_basedn" {
  type = string
}
variable "ldap_filter" {
  type = string
}

variable "ldap_user" {
  type = string
}
variable "ldap_pass" {
  type = string
}

variable "ingress_base_group" {
  type = string
}
variable "ingress_admin_group" {
  type = string
}

variable "tool_email" {
  type = map(string)
  default = {
    "from"     = ""
    "password" = ""
    "port"     = ""
    "server"   = ""
    "tls"      = ""
    "user"     = ""
    "to"       = ""
  }

}
variable "duo_authelia" {
  type = object({
    api_hostname    = string
    integration_key = string
    secret_key      = string
  })
}
