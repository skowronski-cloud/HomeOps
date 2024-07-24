resource "routeros_wifi_configuration" "parent2" {
  name      = "parent2"
  ssid      = "parent2"
  hide_ssid = true
  mode      = "ap"
}
resource "routeros_wifi_configuration" "parent5" {
  name      = "parent5"
  ssid      = "parent5"
  hide_ssid = true
  mode      = "ap"
}

resource "routeros_wifi_configuration" "cfg2" {
  for_each  = var.wireless_config
  name      = "${each.key}2"
  mode      = "ap"
  ssid      = each.value.auth.ssid
  country   = var.country
  chains    = each.value.chains
  tx_chains = each.value.chains
  manager   = "capsman"
  channel = {
    band              = each.value["2ghz"].band
    width             = each.value["2ghz"].width
    skip_dfs_channels = var.skip_dfs_channels
    reselect_interval = var.reselect_interval
  }
  security = {
    authentication_types = each.value.auth.types
    ft                   = each.value.ft
    ft_preserve_vlanid   = each.value.ft
    ft_over_ds           = each.value.ft
    connect_priority     = 0
    passphrase           = each.value.auth.pass
  }
}
resource "routeros_wifi_configuration" "cfg5" {
  for_each  = var.wireless_config
  name      = "${each.key}5"
  mode      = "ap"
  ssid      = each.value.auth.ssid
  country   = var.country
  chains    = each.value.chains
  tx_chains = each.value.chains
  manager   = "capsman"
  channel = {
    band              = each.value["5ghz"].band
    width             = each.value["5ghz"].width
    skip_dfs_channels = var.skip_dfs_channels
    reselect_interval = var.reselect_interval
  }
  security = {
    authentication_types = each.value.auth.types
    ft                   = each.value.ft
    ft_preserve_vlanid   = each.value.ft
    ft_over_ds           = each.value.ft
    connect_priority     = 0
    passphrase           = each.value.auth.pass
  }
}
