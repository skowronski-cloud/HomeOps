resource "kubernetes_manifest" "alertmanager_silences" {
  manifest = {
    apiVersion = "monitoring.coreos.com/v1alpha1"
    kind       = "AlertmanagerConfig"
    metadata = {
      name      = "alertmanager-silences"
      namespace = "monitoring-system"
      labels = {
        managed_by = "terraform"
      }
    }
    spec = {
      route = {
        receiver = "blackhole"
        continue = false

        matchers = [
          {
            name      = "alertname"
            matchType = "=~"
            value     = "^(KubeControllerManagerDown)$"
            # https://github.com/k0sproject/k0s/issues/3759
          }
        ]
      }
      receivers = [
        {
          name = "blackhole"
        }
      ]
    }
  }
}
