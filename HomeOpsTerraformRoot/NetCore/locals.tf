locals {
  net_segments = {
    for entry in var.net_segments :
    entry.id => entry
  }
}
