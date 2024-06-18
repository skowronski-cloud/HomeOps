resource "routeros_interface_ethernet" "wan" {
  factory_name = var.wan_port
  name         = var.wan_port
  mac_address  = var.wan_mac
}

resource "routeros_interface_vlan" "wan" {
  interface = routeros_interface_ethernet.wan.name
  name      = "vlan${var.wan_vlan}"
  vlan_id   = var.wan_vlan
}

resource "routeros_ip_dhcp_client" "wan" {
  interface         = routeros_interface_vlan.wan.name
  add_default_route = "yes"
}

resource "routeros_interface_list" "wan" {
  name = "WAN"
}
resource "routeros_interface_list_member" "wan" {
  interface = routeros_interface_vlan.wan.name
  list      = routeros_interface_list.wan.name
}
