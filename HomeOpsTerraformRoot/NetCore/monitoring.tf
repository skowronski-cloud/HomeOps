resource "routeros_tool_netwatch" "probe" {
  for_each         = var.netwatch_probes
  name             = each.key
  host             = each.value.host
  disabled         = each.value.disabled
  interval         = each.value.interval
  port             = each.value.tcp_port
  packet_count     = each.value.ping_packet_count
  thr_avg          = each.value.ping_thr_avg
  thr_max          = each.value.ping_thr_max
  thr_stdev        = each.value.ping_thr_stddev
  thr_jitter       = each.value.ping_thr_jitter
  thr_loss_percent = each.value.ping_thr_loss
  timeout          = each.value.timeout
  ttl              = each.value.ping_ttl
  type             = each.value.type
  comment          = each.value.comment
}
resource "routeros_system_user_group" "monitoring" {
  name    = "monitoring"
  policy  = ["api", "read"]
  comment = "monitoring: read and api only"
}

resource "random_password" "monitoring" {
  length  = 64
  special = false
}

resource "routeros_system_user" "monitoring_prometheus" {
  name     = "monitoring"
  address  = "0.0.0.0/0"
  group    = "monitoring"
  password = resource.random_password.monitoring.result
  comment  = "monitoring user for prometheus exporters on yig"
}
output "monitoring_prometheus_auth" {
  value = {
    user     = routeros_system_user.monitoring_prometheus.name
    password = routeros_system_user.monitoring_prometheus.password
  }
}
