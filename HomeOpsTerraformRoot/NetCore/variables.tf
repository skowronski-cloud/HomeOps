variable "wan_mac" {
  type = string
}
variable "wan_vlan" {
  type = number
}
variable "wan_port" {
  type = string
}
variable "lan_ports" {
  type = map(string)
}
variable "lan_addr" {
  type = string
}
variable "lan_mask" {
  type = number
}
variable "identity" {
  type = string
}
variable "dns" {
  type = list(string)
}
variable "local_tld" {
  type = string
}
variable "dhcp_servers" {
  type = map(map(string))
}
variable "hex" {
  type = map(string)
}
variable "caps" {
  type = map(map(string))
}
variable "net_segments" {
  type = list(map(string))
  default = [{
    "id"      = "a"
    "third"   = "100"
    "name"    = "dns-friendly-name"
    "start"   = "192.168.1.10"
    "end"     = "192.168.1.11"
    "comment" = "optional"
  }]
}
variable "tool_email" {
  type = map(string)
  default = {
    "from"     = ""
    "password" = ""
    "port"     = ""
    "server"   = ""
    "tls"      = ""
    "user"     = ""
    "to"       = ""
  }
}
variable "dhcp_notify_match" {
  type    = string
  default = "192.168..*"
}
variable "admin_ssh_key" {
  type = string 
}