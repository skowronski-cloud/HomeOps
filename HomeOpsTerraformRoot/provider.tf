provider "routeros" {
  alias    = "hex"
  hosturl  = "http://${var.ros_hex.addr}/"
  username = var.ros_hex.user
  password = var.ros_hex.pass
  insecure = true
}
provider "kubernetes" {
  config_path    = "~/.kube/config"
  config_context = "yig"
}
provider "helm" {
  kubernetes = {
    config_path    = "~/.kube/config"
    config_context = "yig"
  }
  burst_limit = 100000
  experiments = {
    manifest = true
  }
}
provider "synology" {
  host       = "https://${var.yig_synology_tf_acct.host}:${var.yig_synology_tf_acct.port}"
  user       = var.yig_synology_tf_acct.user
  password   = var.yig_synology_tf_acct.pass
  otp_secret = var.yig_synology_tf_acct.otp
}
provider "pagerduty" {
  token = var.pagerduty.admin_token
}

provider "ldap" {
  host     = var.tf_ldap.host
  port     = var.tf_ldap.port
  bind_user     = var.tf_ldap.user
  bind_password = var.tf_ldap.pass
  tls           = var.tf_ldap.tls
  tls_insecure = var.tf_ldap.tls_insecure
}