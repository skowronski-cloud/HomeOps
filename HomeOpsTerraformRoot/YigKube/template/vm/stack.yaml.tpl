---
# https://artifacthub.io/packages/helm/victoriametrics/victoria-metrics-k8s-stack?modal=values
external:
  grafana:
    host: kube-prometheus-stack-grafana.monitoring-system.svc
vmsingle:
  enabled: false
vmcluster:
  ingress:
    select:
      enabled: true
      hosts:
        - vm-select.${ingress_domain}
      annotations:
        gethomepage.dev/enabled: "true"
        gethomepage.dev/name: "VictoriaMetrics Select"
        gethomepage.dev/icon: sh-victoriametrics
        gethomepage.dev/group: "Admin"
        gethomepage.dev/external: "true"
    insert:
      enabled: true
      hosts:
        - vm-insert.${ingress_domain}
      annotations:
        gethomepage.dev/enabled: "true"
        gethomepage.dev/name: "VictoriaMetrics Insert"
        gethomepage.dev/icon: sh-victoriametrics
        gethomepage.dev/group: "Admin"
        gethomepage.dev/external: "true"
  enabled: true
  spec:
    replicationFactor: 2
    retainPeriod: ${retention}
    vmstorage:
      replicaCount: 3
      enabled: true
      storage:
        volumeClaimTemplate:
          spec:
            #storageClassName: ${storage_class_name}
            resources:
              requests:
                storage: ${storage_size}
    vmselect:
      enabled: true
      replicaCount: 2
      storage:
        volumeClaimTemplate:
          spec:
            resources:
              requests:
                storage: 2Gi
    vminsert:
      enabled: true
      replicaCount: 2

alertmanager:
  enabled: false # not yet
vmalert:
  enabled: false # not yet
vmagent:
  enabled: true
prometheus-node-exporter:
  enabled: false
kube-state-metrics:
  enabled: false
kubelet:
  enabled: false
kubeApiServer:
  enabled: false
kubeControllerManager:
  enabled: false
kubeDns:
  enabled: false
coreDns:
  enabled: false
kubeEtcd:
  enabled: false
kubeScheduler:
  enabled: false
kubeProxy:
  enabled: false

grafana:
  enabled: false

vmauth:
  enabled: true
  spec:
    unauthorizedUserAccessSpec:
      disabled: true