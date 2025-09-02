variable "ros_hex" {
  type        = map(string)
  description = "main RouterOS device"
  default = {
    "addr"      = "192.168.88.1"
    "user"      = "admin"
    "pass"      = ""
    "identity"  = "hEX"
    "device"    = "-----------"
    "serial"    = "-----------"
    "ether1mac" = "00:00:DE:AD:BE:EF"
  }
}
variable "ros_caps" {
  type        = map(map(string))
  description = "map of RouterOS AP devices; key is device identity"
  default = {
    "hAP-1" = {
      "addr"      = "192.168.88.3"
      "user"      = "admin"
      "pass"      = ""
      "identity"  = "hAP-1"
      "device"    = "-----------"
      "serial"    = "-----------"
      "ether1mac" = "00:00:DE:AD:BE:EF"
    }
    "hAP-1" = {
      "addr"      = "192.168.88.4"
      "user"      = "admin"
      "pass"      = ""
      "identity"  = "hAP-2"
      "device"    = "-----------"
      "serial"    = "-----------"
      "ether1mac" = "00:00:DE:AD:BE:EF"
    }
  }
}


variable "wan_mac" {
  type        = string
  description = "MAC to spoof for ISP"
}
variable "wan_vlan" {
  type        = number
  description = "ISP VLAN"
}
variable "wan_port" {
  type        = string
  description = "port on hEX to connect to WAN"
  default     = "ether1"
}
variable "lan_ports" {
  type        = map(string)
  description = "map of ports on hEX to treat as LAN; values doesn't matter - only keys are used"
  default     = { "ether2" = "", "ether3" = "", "ether4" = "", "ether5" = "" }
}

variable "lan_mask" {
  type        = number
  description = "network mask to be used on main LAN address (IP taken from ros_hex.addr)"
  default     = 24
}

variable "dns" {
  type        = list(string)
  description = "upstream/public DNS servers"
  default     = ["1.1.1.1", "1.0.0.1"]
}
variable "local_tld" {
  type        = string
  description = "local domain to be used with local DNS server"
  default     = "local"
}
variable "dhcp_servers" {
  type        = map(map(string))
  description = "map of DHCP servers"
  default = {
    "dhcp1" = {
      "pool"      = "dhcp_pool"
      "interface" = "bridge"
      "comment"   = "..."
    }
  }
}

variable "country" {
  type    = string
  default = "Poland"
}
variable "wireless_config" {
  // FIXME - schema
}
variable "repo_root" {
  type = string
  # MANAGED FROM TERRAGRUNT
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
  type        = string
  description = "SSH public key for admin user"
}
