#resource "routeros_wifi_security" "sec" {
#  for_each             = var.wireless_config
#  name                 = each.key
#  authentication_types = each.value.auth.types
#  ft                   = true
#  ft_preserve_vlanid   = false
#  ft_over_ds           = false
#  connect_priority     = 0
#  passphrase           = each.value.auth.pass
#}
