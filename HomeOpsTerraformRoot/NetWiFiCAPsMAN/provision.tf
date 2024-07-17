resource "routeros_wifi_provisioning" "prov2" {
  action               = "create-dynamic-enabled"
  master_configuration = routeros_wifi_configuration.parent2.name
  slave_configurations = [for k, v in routeros_wifi_configuration.cfg2 : v.name]
  name_format          = "%I2"
  comment              = "2GHz"
  supported_bands      = ["2ghz-ax"]
}
resource "routeros_wifi_provisioning" "prov5" {
  action               = "create-dynamic-enabled"
  master_configuration = routeros_wifi_configuration.parent5.name
  slave_configurations = [for k, v in routeros_wifi_configuration.cfg5 : v.name]
  name_format          = "%I5"
  comment              = "5GHz"
  supported_bands      = ["5ghz-ax"]
}
