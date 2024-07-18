module "dhcp" {
  source = "./NetClients/"
  providers = {
    routeros = routeros.hex
  }
  dhcp      = csvdecode(file("${var.repo_root}/../HomeOpsData/dhcp.csv"))
  local_tld = var.local_tld
}

