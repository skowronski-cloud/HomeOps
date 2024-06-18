resource "routeros_ip_pool" "pool" {
  for_each  = var.dhcp_pools
  name      = each.key
  ranges    = ["${each.value.first}-${each.value.last}"]
  comment   = each.value.comment
  next_pool = each.value.next_pool
}
resource "routeros_ip_dhcp_server" "server" {
  for_each  = var.dhcp_servers
  name      = each.key
  comment   = each.value.comment
  interface = each.value.interface
}
resource "routeros_ip_dhcp_server_lease" "hex" {
  address     = var.hex.addr
  mac_address = var.hex.ether1mac
  comment = jsonencode({
    "hostname" : "net-${var.hex.identity}",
    "device" : var.hex.device,
    "serial" : var.hex.serial,
    "roles" : ["hEX", "DHCP"]
  })
}
resource "routeros_ip_dns_record" "hex" {
  name    = "hex.${var.local_tld}"
  address = var.lan_addr
  type    = "A"
}

resource "routeros_ip_dhcp_server_lease" "capsman" {
  address     = var.capsman.addr
  mac_address = var.capsman.ether1mac
  comment = jsonencode({
    "hostname" : "net-${var.capsman.identity}",
    "device" : var.capsman.device,
    "serial" : var.capsman.serial,
    "roles" : ["CAPsMAN", "CAP"]
  })
}
resource "routeros_ip_dns_record" "capsman" {
  name    = "capsman.${var.local_tld}"
  address = var.capsman.addr
  type    = "A"
}

resource "routeros_ip_dhcp_server_lease" "cap" {
  for_each    = var.caps
  address     = each.value.addr
  mac_address = each.value.ether1mac
  comment = jsonencode({
    "hostname" : "net-${each.key}",
    "device" : each.value.device,
    "serial" : each.value.serial,
    "roles" : ["CAP"]
  })
}
