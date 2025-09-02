resource "routeros_ip_pool" "pool" {
  for_each = local.net_segments
  name     = "pool${each.value.third}"
  ranges   = ["${each.value.start}-${each.value.end}"]
  comment = jsonencode({
    "net"     = each.value.id,
    "third"   = each.value.third,
    "name"    = each.value.name,
    "comment" = each.value.comment,
  })
}
resource "routeros_ip_dhcp_server" "server" {
  for_each     = var.dhcp_servers
  name         = each.key
  comment      = each.value.comment
  interface    = each.value.interface
  address_pool = each.value.address_pool
  lease_script = templatefile("${path.module}/lease_script.tpl", {
    dhcp_notify_match = var.dhcp_notify_match,
    tool_email_to     = var.common_smtp.to,
  })
}
resource "routeros_ip_dns_record" "hex" {
  name    = "hex.${var.local_tld}"
  address = var.lan_addr
  type    = "A"
}
