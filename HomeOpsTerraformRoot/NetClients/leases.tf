
resource "routeros_ip_dhcp_server_lease" "lease" {
  for_each    = local.leases
  address     = replace(each.value.ip, "/\\.(0+)([0-9]+)/", ".$2")
  mac_address = each.value.mac
  comment = jsonencode({
    "hostname" : "net-${each.key}",
    "vendor" : each.value.device,
    "device" : each.value.device,
    "serial" : each.value.device,
    "comment" : each.value.comment,
    "serial" : each.value.serial,
  })
}
