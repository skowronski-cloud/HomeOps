resource "routeros_system_identity" "name" {
  name = var.identity
}

resource "routeros_dns" "dns" {
  allow_remote_requests = true
  servers               = var.dns
}

resource "routeros_tool_email" "email" {
  from     = var.tool_email.from
  password = var.tool_email.password
  port     = var.tool_email.port
  server   = var.tool_email.server
  tls      = var.tool_email.tls
  user     = var.tool_email.user
}
