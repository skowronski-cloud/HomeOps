#resource "routeros_ip_dns_record" "alias" {
#  for_each = local.extra_addresses
#  name     = "${each.key}.${var.local_tld}"
#  address  = replace(each.value.ip, "/\\.(0+)([0-9]+)/", ".$2")
#  type     = "A"
#}
