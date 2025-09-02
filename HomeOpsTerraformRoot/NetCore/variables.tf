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
variable "tool_email_from" {
  type = string
}
variable "common_smtp" {
  type = object({
    from     = optional(string)
    password = string
    port     = string
    server   = string
    tls      = string
    user     = string
    to       = string
  })
}
variable "dhcp_notify_match" {
  type    = string
  default = "192.168..*"
}
variable "admin_ssh_key" {
  type = string
}
variable "netwatch_probes" {
  type = map(object({
    host              = string
    disabled          = optional(bool, false)
    interval          = optional(string, "00:01:00")
    tcp_port          = optional(number, null)
    ping_ttl          = optional(number, 16)
    ping_packet_count = optional(number, 3)
    ping_thr_avg      = optional(string, null)
    ping_thr_max      = optional(string, null)
    ping_thr_stddev   = optional(string, null)
    ping_thr_jitter   = optional(string, null)
    ping_thr_loss     = optional(number, 50) # %
    timeout           = optional(string, "00:00:15")
    type              = optional(string, "icmp") # icmp or tcp-conn or http-get
    comment           = optional(string)
  }))
}
