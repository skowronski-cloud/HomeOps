module "core" {
  source = "./NetCore/"
  providers = {
    routeros = routeros.hex
  }
  wan_mac      = var.wan_mac
  wan_vlan     = var.wan_vlan
  wan_port     = var.wan_port
  lan_ports    = var.lan_ports
  lan_addr     = var.ros_hex.addr
  lan_mask     = var.lan_mask
  identity     = var.ros_hex.identity
  dns          = var.dns
  local_tld    = var.local_tld
  dhcp_servers = var.dhcp_servers

  hex               = var.ros_hex
  caps              = var.ros_caps
  net_segments      = csvdecode(file("${var.repo_root}/../HomeOpsData/net_segments.csv"))
  tool_email_from   = var.tool_email_from
  common_smtp       = var.common_smtp
  dhcp_notify_match = var.dhcp_notify_match

  admin_ssh_key   = var.admin_ssh_key
  netwatch_probes = var.netwatch_probes
}

variable "tool_email_from" {
  type = string
}
variable "netwatch_probes" { # TODO: shouldn't that be in monitoring?
  type = map(object({
    host              = string # FIXME: now only IPs work (ROS limitation), maybe it'd be better to add rewriter in TF to fetch IPs from DHCP leases?
    disabled          = optional(bool)
    interval          = optional(string)
    tcp_port          = optional(number)
    ping_ttl          = optional(number)
    ping_packet_count = optional(number)
    ping_thr_avg      = optional(string)
    ping_thr_max      = optional(string)
    ping_thr_stddev   = optional(string)
    ping_thr_jitter   = optional(string)
    ping_thr_loss     = optional(number)
    timeout           = optional(string)
    type              = optional(string) # icmp or tcp-conn or http-get
    comment           = optional(string)
  }))
  default = {
    "cloudflare" = {
      host = "1.1.1.1"
    }
  }
}
