resource "routeros_system_identity" "name" {
  name = var.identity
}

resource "routeros_dns" "dns" {
  allow_remote_requests = true
  servers               = var.dns
}

resource "routeros_tool_email" "email" {
  from     = var.tool_email_from
  password = var.common_smtp.password
  port     = var.common_smtp.port
  server   = var.common_smtp.server
  tls      = var.common_smtp.tls
  user     = var.common_smtp.user
}

resource "routeros_system_user_sshkeys" "admin" {
  user    = "admin"
  key     = var.admin_ssh_key
  comment = "admin"
}

# TODO: https://registry.terraform.io/providers/terraform-routeros/routeros/latest/docs/resources/system_certificate
