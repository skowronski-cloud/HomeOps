vmagent:
  enabled: true
  ingress:
    enabled: true
    hosts:
      - vm-agent.${ingress_domain}
    annotations:
      gethomepage.dev/enabled: "true"
      gethomepage.dev/name: "VictoriaMetrics Agent"
      gethomepage.dev/icon: sh-victoriametrics
      gethomepage.dev/group: "Admin"
      gethomepage.dev/external: "true"
  spec:
    replicaCount: 2
    scrapeInterval: 20s
    resources:
      requests:
        cpu: 250m
        memory: 256Mi
      limits:
        cpu: 500m
        memory: 512Mi
    externalLabelName: vmagent_ha
    statefulMode: true
    statefulStorage:
      volumeClaimTemplate:
        spec:
          accessModes:
            - ReadWriteOnce
          resources:
            requests:
              storage: 10Gi
    podDisruptionBudget:
      minAvailable: 1
    inlineScrapeConfig: |
      - job_name: kubernetes-pods
        kubernetes_sd_configs:
          - role: pod

        relabel_configs:
          # Select annotated pods.
          - action: keep
            source_labels:
              - __meta_kubernetes_pod_annotation_prometheus_io_scrape
            regex: "true"

          # Skip init containers.
          - action: drop
            source_labels: [__meta_kubernetes_pod_container_init]
            regex: "true"

          # Select the declared container port matching the annotation.
          - action: keep_if_equal
            source_labels:
              - __meta_kubernetes_pod_annotation_prometheus_io_port
              - __meta_kubernetes_pod_container_port_number

          # Optional scheme; defaults to HTTP.
          - source_labels:
              - __meta_kubernetes_pod_annotation_prometheus_io_scheme
            regex: "(https?)"
            target_label: __scheme__

          # Optional path; defaults to /metrics.
          - source_labels:
              - __meta_kubernetes_pod_annotation_prometheus_io_path
            regex: "(.+)"
            target_label: __metrics_path__

          - source_labels: [__meta_kubernetes_namespace]
            target_label: namespace
          - source_labels: [__meta_kubernetes_pod_name]
            target_label: pod
          - source_labels: [__meta_kubernetes_pod_container_name]
            target_label: container
          - source_labels: [__meta_kubernetes_pod_node_name]
            target_label: node