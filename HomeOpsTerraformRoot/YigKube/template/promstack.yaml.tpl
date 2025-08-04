grafana:
  enabled: true
  adminPassword: "${grafana_admin_pass}"
  ingress:
    enabled: true
    ingressClassName: "traefik"
    hosts:
      - grafana.${ingress_domain}
  useStatefulSet: true
  persistence:
    enabled: true
    accessModes: ["ReadWriteOnce"]
    size: 10Gi
    lookupVolumeName: false # this breaks tfstate!
  service:
    type: ClusterIP
  grafana.ini:
    server:
      root_url: https://grafana.${ingress_domain}
    users:
      auto_assign_org: true
      auto_assign_org_role: Viewer
    auth.proxy:
      enabled: false
      header_name: X-WEBAUTH-USER
      header_property: username
      auto_sign_up: true
      headers: Role:X-WEBAUTH-ROLE
      whitelist: 10.0.0.0/8
    auth.generic_oauth:
      enabled: true
      name: "Yig Grafana"
      auth_url: "https://authelia.${ingress_domain}/api/oidc/authorization"
      token_url: "https://authelia.${ingress_domain}/api/oidc/token"
      api_url: "https://authelia.${ingress_domain}/api/oidc/userinfo"
      client_id: $__file{/etc/secrets/auth_generic_oauth/client-id} 
      client_secret: $__file{/etc/secrets/auth_generic_oauth/client-secret}
      role_attribute_path: contains(groups[*], '${ingress_admin_group}') && 'Admin' || 'Viewer'
      scopes: openid profile email groups
      empty_scopes: false
      allow_sign_up: true
      auto_login: false
      use_pkce: true
      use_refresh_token: true
      tls_client_ca: /certs/ca.crt
    security:
      cookie_samesite: null
      cookie_secure: true
  extraSecretMounts:
    - name: oidc-grafana-client-mount
      secretName: oidc-grafana-client
      defaultMode: 0440
      mountPath: /etc/secrets/auth_generic_oauth
      readOnly: true
    - name: ca-crt-mount
      secretName: ca-crt
      defaultMode: 0440
      mountPath: /certs/
      readOnly: true


alertmanager:
  enabled: true
  alertmanagerSpec:
    replicas: 1 # ${replicas} # TODO: this is not a way to get HA
    storage:
      volumeClaimTemplate:
        spec:
          accessModes: ["ReadWriteOnce"]
          resources:
            requests:
              storage: 10Gi
  ingress:
    enabled: true
    ingressClassName: "traefik"
    annotations: []
    hosts:
      - alertmanager.${ingress_domain}

prometheus:
  enabled: true
  ingress:
    enabled: true
    ingressClassName: "traefik"
    annotations: []
    hosts:
      - prometheus.${ingress_domain}
  prometheusSpec:
    scrapeInterval: 30s
    evaluationInterval: 30s
    retention: "90d"
    replicas: 1 # TODO: this is not a way to get HA, probably need to use Thanos
    serviceMonitorSelector:
      #matchLabels:
      #  release: kube-prometheus-stack
      matchExpressions:
        - key: release
          operator: In
          values: 
            - kube-prometheus-stack
            - prometheus-blackbox-exporter
    storageSpec:
      volumeClaimTemplate:
        labels:
          skipQuickBackup: "true"
        spec:
          accessModes: ["ReadWriteOnce"]
          resources:
            requests:
              storage: 50Gi
    additionalScrapeConfigs:
      - job_name: 'kubernetes-pods'
        kubernetes_sd_configs:
          - role: pod
        relabel_configs:
          - source_labels: [__meta_kubernetes_pod_annotation_prometheus_io_scrape]
            action: keep
            regex: "true"

nodeExporter:
  enabled: true
  hostNetwork: true
  hostPID: true
  service:
    type: ClusterIP
