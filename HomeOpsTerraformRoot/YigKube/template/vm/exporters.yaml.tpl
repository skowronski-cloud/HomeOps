---
prometheus-node-exporter:
  enabled: true
kube-state-metrics:
  enabled: true
kubelet:
  enabled: true
kubeApiServer:
  enabled: true
kubeControllerManager:
  enabled: true
kubeDns:
  enabled: true
coreDns:
  enabled: true
kubeEtcd:
  enabled: true
kubeScheduler:
  enabled: true
kubeProxy:
  enabled: true
  vmScrape:
    spec:
      endpoints:
        - scheme: http  # k0s has HTTP endpoint
