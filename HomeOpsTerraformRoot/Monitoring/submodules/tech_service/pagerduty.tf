resource "pagerduty_service" "svc" {
  name                    = var.pd_name
  description             = "${var.pd_description}\n\nManaged by Terraform in Kuberneres as ${var.namespace}${var.id}."
  auto_resolve_timeout    = "null"
  acknowledgement_timeout = "null"
  escalation_policy       = var.pd_esc_policy
  incident_urgency_rule {
    type    = "constant"
    urgency = "severity_based"
  }
}
resource "pagerduty_service_integration" "integration" {
  name    = "Prometheus Alertmanager - ${var.id}"
  type    = "events_api_v2_inbound_integration"
  service = pagerduty_service.svc.id
}
resource "kubernetes_secret" "pd_rk" {
  metadata {
    name      = "pagerduty-${var.id}"
    namespace = var.namespace
    labels = {
      managed_by = "terraform"
    }
  }
  data = {
    routing_key = pagerduty_service_integration.integration.integration_key
  }
}
