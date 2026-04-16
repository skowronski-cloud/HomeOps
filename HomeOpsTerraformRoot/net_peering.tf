module "net_peering" {
  source = "./NetPeering/"
  providers = {
    routeros = routeros.hex
    kubernetes = kubernetes
  }
  router_ip   = var.bgp_router_ip
  router_asn  = var.bgp_router_asn
  metallb_asn = var.bgp_metallb_asn
  metallb_ips = var.bgp_metallb_ips
  password    = var.bgp_password
  bgp_prefixes = var.bgp_prefixes
}
variable "bgp_router_ip" {
  description = "The IP address of the BGP router."
  type        = string
}
variable "bgp_router_asn" {
  description = "The ASN of the BGP router."
  type        = number
  default     = 64512
}
variable "bgp_metallb_asn" {
  description = "The ASN used by MetalLB."
  type        = number
  default = 64513
}
variable "bgp_metallb_ips" {
  description = "The IP addresses used by MetalLB for BGP peering."
  type        = list(string)
}
variable "bgp_password" {
  description = "The password used for BGP peering."
  type        = string
}
variable "bgp_prefixes" {
  description = "The IP prefixes to be advertised via BGP."
  type        = list(string)
}