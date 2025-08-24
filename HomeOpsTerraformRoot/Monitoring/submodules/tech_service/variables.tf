variable "namespace" {
  type        = string
  description = "Kubernetes namespace where the service is running"
  default     = "monitoring-system"
}
variable "id" {
  type        = string
  description = "Short identifier for this service"
}
variable "pd_esc_policy" {
  type        = string
  description = "PagerDuty escalation policy ID to use for this service"
}
variable "pd_name" {
  type        = string
  description = "Name of the PagerDuty service"
}
variable "pd_description" {
  type        = string
  description = "Description of the PagerDuty service"
}
variable "prom_svc_label" {
  type        = string
  description = "Value of the 'monitor_svc' label in Prometheus to match alerts for this service. Skipped if empty."
  default     = ""
}
variable "matchers" {
  type = list(object({
    name  = string
    value = string
    type  = optional(string, "=")
  }))
  description = "List of additional Prometheus label matchers to select alerts for this service. Skipped if empty."
  default     = []
}
variable "group_by" {
  type        = list(string)
  description = "List of Prometheus labels to group alerts by for this service."
  default     = []
}
