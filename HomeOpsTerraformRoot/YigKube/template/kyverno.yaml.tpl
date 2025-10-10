---
config:
  resourceFiltersExclude:
    - '[*/*,kube-system,*]'
features:
  omitEvents:
    eventTypes: []

admissionController:
  serviceMonitor:
    enabled: true
    additionalLabels:
      release: ${metrics_label_release}
backgroundController:
  serviceMonitor:
    enabled: true
    additionalLabels:
      release: ${metrics_label_release}
cleanupController:
  serviceMonitor:
    enabled: true
    additionalLabels:
      release: ${metrics_label_release}
reportsController:
  serviceMonitor:
    enabled: true
    additionalLabels:
      release: ${metrics_label_release}
