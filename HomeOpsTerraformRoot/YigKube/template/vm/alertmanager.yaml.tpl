---
alertmanager:
  enabled: true
  spec:
    externalURL: https://vm-alertmanager.${ingress_domain}
    replicaCount: 2
    podDisruptionBudget:
      minAvailable: 1
    disableNamespaceMatcher: true
    storage:
      volumeClaimTemplate:
        spec:
          accessModes:
            - ReadWriteOnce
          resources:
            requests:
              storage: 1Gi
  ingress:
    enabled: true
    hosts:
      - vm-alertmanager.${ingress_domain}
    annotations:
      gethomepage.dev/enabled: "true"
      gethomepage.dev/name: "VictoriaMetrics Alertmanager"
      gethomepage.dev/icon: sh-victoriametrics
      gethomepage.dev/group: "Admin"
      gethomepage.dev/external: "true"
