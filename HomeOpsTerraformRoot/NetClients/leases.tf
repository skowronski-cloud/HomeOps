resource "routeros_ip_dhcp_server_lease" "lease" {
  for_each    = local.leases
  address     = replace(each.value.ip, "/\\.(0+)([0-9]+)/", ".$2")
  mac_address = upper(each.value.mac)
  #comment     = "${each.value.net}-${each.value.name}"
  comment = jsonencode({
    "net"     = each.value.net,
    "name"    = each.value.name,
    "comment" = each.value.comment,
  })
}
