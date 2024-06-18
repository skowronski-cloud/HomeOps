module "core" {
  source = "./NetCore/"
  providers = {
    routeros = routeros.hex
  }
  wan_mac      = var.wan_mac
  wan_vlan     = var.wan_vlan
  wan_port     = var.wan_port
  lan_ports    = var.lan_ports
  lan_addr     = var.ros_hex.addr
  lan_mask     = var.lan_mask
  identity     = var.ros_hex.identity
  dns          = var.dns
  local_tld    = var.local_tld
  dhcp_pools   = var.dhcp_pools
  dhcp_servers = var.dhcp_servers

  hex     = var.ros_hex
  capsman = var.ros_capsman
  caps    = var.ros_caps
}
