locals {
  leases = {
    for name, entry in var.net_dhcp :
    upper(entry.mac) => entry
    if entry.ip != ""
    && entry.mac != ""
    && entry.name != ""
  }
}
