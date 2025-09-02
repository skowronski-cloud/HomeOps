module "dhcp" {
  source = "./NetClients/"
  providers = {
    routeros = routeros.hex
  }
  local_tld = var.local_tld
  net_dhcp  = csvdecode(file("${var.repo_root}/../HomeOpsData/net_dhcp.csv"))
  dns_alias = var.net_dns_alias
}

variable "net_dns_alias" {
  type        = map(string)
  default     = {}
  description = "map of DNS aliases to main hostnames without, e.g., { 'alias' = 'name.net'  }"
}
