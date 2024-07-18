locals {
  leases = {
    for entry in var.dhcp :
    entry.name => entry
    if entry.ip != ""
    && entry.mac != ""
    && entry.name != ""
  }
  extra_addresses = {
    for name, entry in local.leases :
    entry.extra_alias => entry
    if entry.extra_alias != ""
  }
}
