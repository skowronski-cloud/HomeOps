resource "kubernetes_manifest" "alertmanager_config" {
  manifest = {
    apiVersion = "monitoring.coreos.com/v1alpha1"
    kind       = "AlertmanagerConfig"
    metadata = {
      name      = "alertmanager-${var.id}"
      namespace = var.namespace
      labels = {
        managed_by = "terraform"
      }
    }
    spec = {
      route = {
        receiver       = "pagerduty-${var.id}"
        groupBy        = var.group_by
        groupWait      = "30s"
        groupInterval  = "5m"
        repeatInterval = "4h"
        matchers = concat(
          var.prom_svc_label != ""
          ? [{
            name  = "monitor_svc"
            type  = "="
            value = var.prom_svc_label
          }]
          : [],
          [for m in var.matchers
            : {
              name      = m.name
              matchType = lookup(m, "type", "=")
              value     = m.value
            }
          ]
        )
      }
      # https://prometheus.io/docs/alerting/latest/notifications/
      receivers = [
        {
          name = "pagerduty-${var.id}"
          pagerdutyConfigs = [
            {
              routingKey = {
                key  = "routing_key"
                name = "pagerduty-${var.id}"
              }
              severity     = "{{ or .CommonLabels.severity \"warning\" }}"
              sendResolved = true
              class        = "{{ .CommonLabels.alertname }}"
              group        = "{{ or .CommonLabels.service \"unknown\" }}"
              client       = "AlertManager"
              clientURL    = "{{ template \"pagerduty.default.clientURL\" . }}"
              component    = "{{ or .CommonLabels.component \"${var.id}\" }}"
              description  = "{{ or .CommonAnnotations.description .CommonAnnotations.summary .CommonLabels.alertname }}"
              details = [
                { key   = "summary"
                  value = "{{ or .CommonAnnotations.summary .CommonLabels.alertname }}"
                },
                { key   = "description"
                  value = "{{ or .CommonAnnotations.description \"\" }}"
                },
                { key   = "runbook"
                  value = "{{ or .CommonAnnotations.runbook \"\" }}"
                },
                { key   = "alertname"
                  value = "{{ or .CommonLabels.alertname \"\" }}"
                },
                { key   = "node"
                  value = "{{ or .CommonLabels.node \"\" }}"
                },
                { key   = "instance"
                  value = "{{ or .CommonLabels.instance \"\" }}"
                },
                { key   = "service"
                  value = "{{ or .CommonLabels.service \"\" }}"
                },
                { key   = "job"
                  value = "{{ or .CommonLabels.job \"\" }}"
                },
                { key   = "namespace"
                  value = "{{ or .CommonLabels.namespace \"\" }}"
                },
              ]
            }
          ]
        }
      ]
    }
  }
}
