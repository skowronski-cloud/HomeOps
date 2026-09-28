module "monitoring" {
  source = "./Monitoring/"
  providers = {
    helm       = helm
    kubernetes = kubernetes
    pagerduty  = pagerduty
    synology   = synology
    tls        = tls
  }
  pagerduty              = var.pagerduty
  synology_tf_acct       = var.yig_synology_tf_acct
  top_domain             = var.yig_top_domain
  ingress_domain         = var.yig_ingress_domain
  yig_ca_crt             = var.yig_ca_crt
  yig_ca_key             = var.yig_ca_key
  victoria_logs          = var.yig_victoria_logs
  victoria_logs_config   = var.yig_victoria_logs_config
  gatus_final_local_icmp = var.gatus_final_local_icmp
  gatus_final_local_tcp  = var.gatus_final_local_tcp
  smarthome_rules_tooHot = var.smarthome_rules_tooHot
}

variable "pagerduty" {
  description = "PagerDuty API token"
  type = object({
    admin_token        = string
    primary_user_email = string
  })
}
variable "yig_synology_tf_acct" {
  description = "Synology account for Terraform, this must be administrator group member as Container Manager lacks RBAC"
  type = object({
    user = string
    pass = string
    host = string
    port = number
    otp  = string
  })
}
variable "yig_victoria_logs" {
  description = "Credentials for the VictoriaLogs deployment; values are supplied by yig.tfvars"
  sensitive   = true
  type = object({
    writer_username     = string
    writer_password     = string
    reader_username     = string
    reader_password     = string
    ingress_proxy_token = string
  })

  validation {
    condition = (
      length(var.yig_victoria_logs.writer_username) > 0 &&
      length(var.yig_victoria_logs.reader_username) > 0 &&
      length(var.yig_victoria_logs.writer_password) >= 24 &&
      length(var.yig_victoria_logs.reader_password) >= 24 &&
      length(var.yig_victoria_logs.ingress_proxy_token) >= 32
    )
    error_message = "VictoriaLogs usernames must be non-empty, passwords at least 24 characters, and the ingress proxy token at least 32 characters."
  }
}
variable "yig_victoria_logs_config" {
  description = "Non-secret site configuration for the VictoriaLogs deployment; values are supplied by monitoring.tfvars"
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
    vlagent_cluster_name                 = string
    vlagent_max_disk_usage               = string
    vlagent_cpu_request                  = string
    vlagent_cpu_limit                    = string
    vlagent_memory_request               = string
    vlagent_memory_limit                 = string
  })

  validation {
    condition     = can(cidrhost("${var.yig_victoria_logs_config.host}/32", 0))
    error_message = "VictoriaLogs host must be an IPv4 address."
  }

  validation {
    condition = (
      alltrue([
        for port in [
          var.yig_victoria_logs_config.api_port,
          var.yig_victoria_logs_config.syslog_port,
          var.yig_victoria_logs_config.syslog_tls_port
        ] : port >= 1 && port <= 65535
      ]) &&
      length(distinct([
        var.yig_victoria_logs_config.api_port,
        var.yig_victoria_logs_config.syslog_port,
        var.yig_victoria_logs_config.syslog_tls_port
      ])) == 3
    )
    error_message = "VictoriaLogs ports must be distinct numbers between 1 and 65535."
  }

  validation {
    condition = (
      startswith(var.yig_victoria_logs_config.synology_project_path, "/") &&
      startswith(var.yig_victoria_logs_config.synology_project_real_path, "/") &&
      var.yig_victoria_logs_config.memory_allowed_percent >= 1 &&
      var.yig_victoria_logs_config.memory_allowed_percent <= 100
    )
    error_message = "VictoriaLogs Synology paths must be absolute and memory_allowed_percent must be between 1 and 100."
  }
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

variable "yig_email_notification_addresses" {
  type = object({
    quire_yig = string
  })
}

variable "smarthome_rules_tooHot" {
  type    = any
  default = {}
}
