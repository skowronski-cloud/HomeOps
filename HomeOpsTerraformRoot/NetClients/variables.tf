variable "local_tld" {
  type    = string
  default = "home"
}
variable "net_dhcp" {
  type = list(map(string))
  default = [{
    "net"     = "a"
    "ip"      = "192.168.9.10"
    "mac"     = "12:34:56:78:90:AB" # or empty to disable
    "name"    = "dns-friendly-name" # or empty to disable
    "comment" = "optional"
  }]
}
