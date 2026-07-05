resource "routeros_routing_bgp_instance" "yig_metallb" {
  name = "yig-metallb"
  as   = var.router_asn
}
resource "routeros_routing_bgp_connection" "yig_peer" {
  for_each         = toset(var.metallb_ips)
  name             = "yig-peer-${replace(each.value, ".", "-")}"
  as               = var.router_asn
  keepalive_time   = "30s"
  remote {
    address = "${each.value}/32"
    as      = var.metallb_asn
  }
  local {
    role = "ebgp"
  }
  tcp_md5_key = var.password
}
resource "routeros_ip_firewall_nat" "nat_bgp" {
  for_each           = toset(var.bgp_prefixes)
  comment            = "NAT for BGP prefix ${each.value}"
  action             = "masquerade"
  chain              = "srcnat"
  out_interface_list = "LAN"
  dst_address        = each.value
}
