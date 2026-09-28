variable "pagerduty" {
  description = "PagerDuty API token"
  type = object({
    admin_token        = string
    primary_user_email = string
  })
}
variable "synology_tf_acct" {
  description = "Synology account for Terraform"
  type = object({
    user = string
    pass = string
    host = string
  })
}

variable "top_domain" {
  type = string
}
variable "ingress_domain" {
  type = string
}
variable "yig_ca_crt" {
  description = "Base64-encoded certificate for the Yig runtime CA"
  type        = string
  sensitive   = true
}
variable "yig_ca_key" {
  description = "Base64-encoded private key for the Yig runtime CA"
  type        = string
  sensitive   = true
}
variable "victoria_logs" {
  description = "Credentials used by VictoriaLogs writers, readers, and the Authelia-protected ingress"
  sensitive   = true
  type = object({
    writer_username     = string
    writer_password     = string
    reader_username     = string
    reader_password     = string
    ingress_proxy_token = string
  })
}
variable "victoria_logs_config" {
  description = "Non-secret site configuration for VictoriaLogs on Synology"
  type = object({
    host                                 = string
    api_port                             = number
    syslog_port                          = number
    syslog_tls_port                      = number
    synology_project_path                = string
    synology_project_real_path           = string
    retention_period                     = string
    retention_max_disk_space_usage_bytes = string
    storage_min_free_disk_space_bytes    = string
    memory_allowed_percent               = number
    victoria_logs_memory_limit           = string
    vmauth_memory_limit                  = string
  })
}
variable "ver_docker_victoria_logs" {
  description = "VictoriaLogs Docker image version"
  type        = string
  default     = "v1.52.0"
}
variable "ver_docker_vmauth" {
  description = "VMAuth Docker image version"
  type        = string
  default     = "v1.152.0"
}
variable "gatus_final_local_icmp" {
  type = map(object({
    host = string
  }))
}
variable "gatus_final_local_tcp" {
  type = map(object({
    description = string
    host        = string
    port        = number
  }))
}
variable "gatus_port" {
  type    = number
  default = 30001
}


variable "smarthome_rules_tooHot" {
  type    = any
  default = {}
}
