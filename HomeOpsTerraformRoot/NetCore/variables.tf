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
variable "dhcp_pools" {
  type = map(map(string))
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
