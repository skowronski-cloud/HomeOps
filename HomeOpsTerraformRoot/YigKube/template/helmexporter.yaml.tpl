---
# https://artifacthub.io/packages/helm/sstarcher/helm-exporter?modal=values
config:
  helmRegistries:
    override:
    - allowAllReleases: true
      charts: []
      registry:
        url: ""
    overrideChartNames: {}
    registryNames: []
grafanaDashboard:
  enabled: true
infoMetric: true
serviceMonitor:
  additionalLabels:
    release: ${metrics_label_release}
  create: true
statusInMetric: true
timestampMetric: true
