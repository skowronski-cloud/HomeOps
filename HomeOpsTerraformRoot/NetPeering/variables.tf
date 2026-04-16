variable "router_ip" {
  description = "The IP address of the BGP router."
  type        = string
}
variable "router_asn" {
  description = "The ASN of the BGP router."
  type        = number
}
variable "metallb_asn" {
  description = "The ASN used by MetalLB."
  type        = number
}
variable "metallb_ips" {
  description = "The IP addresses used by MetalLB for BGP peering."
  type        = list(string)
}
variable "password" {
  description = "The password used for BGP peering."
  type        = string
}

variable "default_labels" {
  type = map(string)
  default = {
    "app.kubernetes.io/managed-by" = "Terraform_HomeOps_NetPeering"
  }
}

variable "namespace" {
  description = "The Kubernetes namespace to deploy the BGP peering resources in."
  type        = string
  default     = "metallb"
}
variable "bgp_prefixes" {
  description = "The IP prefixes to be advertised via BGP."
  type        = list(string)
}