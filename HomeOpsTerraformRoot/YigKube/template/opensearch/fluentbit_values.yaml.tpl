---
# https://artifacthub.io/packages/helm/fluent/fluent-bit?modal=values
kind: DaemonSet
serviceMonitor:
  enabled: true
  selector:
    release: ${ metrics_label_release }
