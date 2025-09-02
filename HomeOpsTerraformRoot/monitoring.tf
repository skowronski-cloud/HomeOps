module "monitoring" {
  source = "./Monitoring/"
  providers = {
    helm       = helm
    kubernetes = kubernetes
    pagerduty  = pagerduty
    synology   = synology
  }
  pagerduty              = var.pagerduty
  synology_tf_acct       = var.yig_synology_tf_acct
  top_domain             = var.yig_top_domain
  ingress_domain         = var.yig_ingress_domain
  gatus_final_local_icmp = var.gatus_final_local_icmp
  gatus_final_local_tcp  = var.gatus_final_local_tcp
}

variable "pagerduty" {
  description = "PagerDuty API token"
  type = object({
    admin_token        = string
    primary_user_email = string
  })
}
variable "yig_synology_tf_acct" {
  description = "Synology account for Terraform, this must be administrator group member as Container Manager lacks RBAC"
  type = object({
    user = string
    pass = string
    host = string
    port = number
    otp  = string
  })
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

variable "yig_email_notification_addresses" {
  type = object({
    quire_yig = string
  })
}
