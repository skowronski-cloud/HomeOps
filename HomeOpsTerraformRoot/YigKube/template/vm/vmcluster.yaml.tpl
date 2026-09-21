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
    retentionPeriod: ${retention}
    vmstorage:
      replicaCount: 3
      enabled: true
      resources:
        requests:
          cpu: 500m
          memory: 2Gi
        limits:
          cpu: "3"
          memory: 3Gi
      extraArgs:
        dedup.minScrapeInterval: 20s
        search.maxQueueDuration: 20s
      storage:
        volumeClaimTemplate:
          spec:
            storageClassName: ${storage_class_name}
            resources:
              requests:
                storage: ${storage_size}
    vmselect:
      enabled: true
      replicaCount: 3
      resources:
        requests:
          cpu: 500m
          memory: 512Mi
        limits:
          cpu: "2"
          memory: 2Gi
      extraArgs:
        dedup.minScrapeInterval: 20s
        search.maxQueueDuration: 20s
      storage:
        volumeClaimTemplate:
          spec:
            resources:
              requests:
                storage: 2Gi
    vminsert:
      enabled: true
      replicaCount: 3
      resources:
        requests:
          cpu: 200m
          memory: 256Mi
        limits:
          cpu: 1000m
          memory: 1Gi
