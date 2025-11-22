---
# https://artifacthub.io/packages/helm/policy-reporter/policy-reporter
ingress:
  enabled: false
  #hosts:
  #  - "kyverno.${ingress_domain}"
metrics:
  enabled: true
monitoring:
  enabled: true
  serviceMonitor:
    labels:
      release: ${metrics_label_release}
ui:
  enabled: true
  ingress:
    enabled: true
    hosts:
      - host: "kyverno.${ingress_domain}"
        paths:
          - path: /
            pathType: ImplementationSpecific
  networkPolicy:
    enabled: true
    ingress:
      - from:
          - namespaceSelector:
              matchLabels:
                app.kubernetes.io/metadata.name: traefik-system


networkPolicy:
  enabled: true
  ingress:
    - from:
        - namespaceSelector:
            matchLabels:
              app.kubernetes.io/metadata.name: traefik-system
