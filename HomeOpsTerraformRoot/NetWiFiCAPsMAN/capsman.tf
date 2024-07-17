resource "routeros_wifi_capsman" "settings" {
  enabled        = true
  interfaces     = ["bridge"]
  upgrade_policy = "suggest-same-version"
}
