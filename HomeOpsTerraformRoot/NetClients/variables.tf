variable "dhcp" {
  type = list(map(string))
  default = [{
    "ip"          = "192.168.9.10"
    "mac"         = "12:34:56:78:90:AB" # or empty to disable
    "name"        = "dns-friendly-name" # or empty to disable
    "vendor"      = "optional"
    "device"      = "optional"
    "serial"      = "optional"
    "comment"     = "optional"
    "extra_alias" = "dns-friendly-name" # or empty to disable
  }]
}
variable "local_tld" {
  type    = string
  default = "home"
}
