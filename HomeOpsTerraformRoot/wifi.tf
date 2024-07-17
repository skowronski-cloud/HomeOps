module "wifi" {
  source = "./NetWiFiCAPsMAN/"
  providers = {
    routeros = routeros.hex
  }
  country         = var.country
  wireless_config = var.wireless_config
}

