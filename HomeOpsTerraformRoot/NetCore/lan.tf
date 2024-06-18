
resource "routeros_interface_bridge" "lan_bridge" {
  name = "bridge"
}
resource "routeros_interface_ethernet" "lan" {
  for_each     = var.lan_ports
  factory_name = each.key
  name         = each.key
}
resource "routeros_interface_bridge_port" "lan" {
  for_each  = var.lan_ports
  bridge    = routeros_interface_bridge.lan_bridge.name
  interface = routeros_interface_ethernet.lan[each.key].name
}

resource "routeros_interface_list" "lan" {
  name = "LAN"
}
resource "routeros_interface_list_member" "lan" {
  interface = routeros_interface_bridge.lan_bridge.name
  list      = routeros_interface_list.lan.name
}

resource "routeros_ip_address" "lan_main" {
  address   = "${var.lan_addr}/${var.lan_mask}"
  interface = routeros_interface_bridge.lan_bridge.name
}
