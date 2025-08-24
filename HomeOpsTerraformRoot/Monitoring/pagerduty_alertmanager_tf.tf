module "tech_service_pagerduty_alertmanager" {
  source   = "./submodules/tech_service"
  for_each = var.monitoring_services

  namespace      = "monitoring-system"
  id             = replace(each.key, "_", "-")
  pd_esc_policy  = data.pagerduty_escalation_policy.default.id
  pd_name        = each.value.pd_name
  pd_description = each.value.pd_description
  prom_svc_label = each.value.prom_svc_label
  matchers       = each.value.matchers
  group_by       = each.value.group_by
}
