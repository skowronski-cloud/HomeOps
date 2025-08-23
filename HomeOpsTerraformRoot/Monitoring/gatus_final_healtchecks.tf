
resource "pagerduty_service" "yf" {
  name                    = "[Yig Final]"
  description             = "Final Health-Checks for Yig, fallback for Prometheus"
  auto_resolve_timeout    = "null"
  acknowledgement_timeout = "null"
  escalation_policy       = data.pagerduty_escalation_policy.default.id
}
resource "pagerduty_service_integration" "yf_gatus" {
  name    = "Gatus Yig Final"
  type    = "events_api_v2_inbound_integration"
  service = pagerduty_service.yf.id
}

# BUG: await https://github.com/synology-community/terraform-provider-synology/pull/121
resource "synology_filestation_folder" "gatus_data" {
  path           = "/docker/gatus/data"
  create_parents = true
}
resource "synology_container_project" "gatus" {
  name       = "gatus"
  share_path = "/docker/gatus"
  run        = true
  services = {
    "gatus" = {
      image        = "twinproduction/gatus:latest"
      network_mode = "host" # required to probe localhost of Synology (hairpin NAT)

      ports = [{
        # FIXME - use Synology proxy
        target    = var.gatus_port
        published = var.gatus_port
      }]

      environment = {
        "PORT" = var.gatus_port
      }

      configs = [
        {
          source = "config_yaml"
          target = "/config/config.yaml"
          gid    = 0
          uid    = 0
          mode   = "0660"
        }
      ]

      logging = { driver = "json-file" }

      volumes = [{
        type             = "bind"
        target           = "/data"
        source           = synology_filestation_folder.gatus_data.real_path
        read_only        = false
        create_host_path = true
      }]
    }
  }

  configs = {
    "config_yaml" = {
      name = "config_yaml"
      content = templatefile("${path.module}/template/synology_gatus.yaml.tpl", {
        pagerduty_yf_key       = pagerduty_service_integration.yf_gatus.integration_key
        ingress_domain         = var.ingress_domain
        gatus_final_local_icmp = var.gatus_final_local_icmp
        gatus_final_local_tcp  = var.gatus_final_local_tcp
        gatus_port             = var.gatus_port
      })
    }
  }
}
