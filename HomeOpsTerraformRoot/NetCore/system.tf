resource "routeros_system_identity" "name" {
  name = var.identity
}

resource "routeros_dns" "dns" {
  allow_remote_requests = true
  servers               = var.dns
}
