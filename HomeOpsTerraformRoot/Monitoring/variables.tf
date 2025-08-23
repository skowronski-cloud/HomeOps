variable "pagerduty" {
  description = "PagerDuty API token"
  type = object({
    admin_token        = string
    primary_user_email = string
  })
}
variable "synology_tf_acct" {
  description = "Synology account for Terraform"
  type = object({
    user = string
    pass = string
    host = string
  })
}

variable "top_domain" {
  type = string
}
variable "ingress_domain" {
  type = string
}
variable "gatus_final_local_icmp" {
  type = map(object({
    host = string
  }))
}
variable "gatus_final_local_tcp" {
  type = map(object({
    description = string
    host        = string
    port        = number
  }))
}
variable "gatus_port" {
  type    = number
  default = 30001
}
