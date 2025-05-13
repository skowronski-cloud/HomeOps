module "dhcp" {
  source = "./NetClients/"
  providers = {
    routeros = routeros.hex
  }
  local_tld = var.local_tld
  net_dhcp  = csvdecode(file("${var.repo_root}/../HomeOpsData/net_dhcp.csv"))
}

