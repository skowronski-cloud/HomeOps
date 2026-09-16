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
  plugins:
    - victoriametrics-metrics-datasource
    - volkovlabs-variable-panel
    - marcusolsson-static-datasource
    - yesoreyeram-infinity-datasource
    - grafana-clock-panel
    - volkovlabs-echarts-panel
    - ekacnet-cubismgrafana-panel
    - marcusolsson-hourly-heatmap-panel
    - grafana-polystat-panel
    - benjaminfourmaux-status-panel
    - fetzerch-sunandmoon-datasource
    - grafana-googlesheets-datasource
    - frser-sqlite-datasource
    - marcusolsson-treemap-panel
    - knightss27-weathermap-panel
    - vaduga-mapgl-panel
    - tailosstg-map-panel
    - equansdatahub-tree-panel
    - pgillich-tree-panel
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
      scopes: openid profile email groups offline_access
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
