---
# https://artifacthub.io/packages/helm/opensearch-project-helm-charts/opensearch?modal=values
clusterName: ${cluster}
nodeGroup: master

singleNode: false
replicas: 3
antiAffinity: hard
maxUnavailable: 1

masterService: ${cluster}-master

openSearchAnnotations:
  secret.reloader.stakater.com/reload: "os-certs,os-admin-certs"

securityConfig:
  enabled: true
  configSecret: securityconfig-secret
  internalUsersSecret: securityconfig-secret
  rolesMappingSecret: securityconfig-secret
  rolesSecret: securityconfig-secret

config:
  opensearch.yml: |
    cluster.name: ${cluster}
    network.host: 0.0.0.0
    logger.level: DEBUG

    opensearch_dashboards.system_indices:
      - ".kibana"
      - ".kibana_*"

    plugins.security.system_indices.enabled: true
    plugins.security.system_indices.permission.enabled: true

    plugins.security.roles_mapping_resolution: BOTH
    plugins.security.config_index_name: ".opendistro_security"
    plugins.security.allow_default_init_securityindex: true

    plugins.security.ssl.transport.pemcert_filepath: /usr/share/opensearch/config/certs/tls.crt
    plugins.security.ssl.transport.pemkey_filepath: /usr/share/opensearch/config/certs/tls.key
    plugins.security.ssl.transport.pemtrustedcas_filepath: /usr/share/opensearch/config/certs/ca.crt
    plugins.security.ssl.transport.enforce_hostname_verification: false

    plugins.security.ssl.http.enabled: true
    plugins.security.ssl.http.pemcert_filepath: /usr/share/opensearch/config/certs/tls.crt
    plugins.security.ssl.http.pemkey_filepath: /usr/share/opensearch/config/certs/tls.key
    plugins.security.ssl.http.pemtrustedcas_filepath: /usr/share/opensearch/config/certs/ca.crt
    plugins.security.ssl.http.clientauth_mode: OPTIONAL

    plugins.security.authcz.admin_dn:
      - "CN=opensearch-admin"
    plugins.security.nodes_dn:
      - "CN=opensearch-nodes"

extraEnvs:
  - name: DISABLE_INSTALL_DEMO_CONFIG
    value: "true"

secretMounts:
  - name: os-certs
    secretName: os-certs
    path: /usr/share/opensearch/config/certs
  - name: os-admin-certs
    secretName: os-admin-certs
    path: /usr/share/opensearch/config/admin-certs

service:
  annotations:
    traefik.ingress.kubernetes.io/service.serversscheme: https

serviceMonitor:
  enabled: true
  scheme: https

persistence:
  enabled: true
  storageClass: ${ storage_class_name }
  size: ${ opensearch_volume_size }

resources:
  requests:
    cpu: 500m
    memory: 1Gi

opensearchJavaOpts: "-Xms512m -Xmx512m"

extraObjects:
  # RSA sub-CA issued by existing ClusterIssuer (yig-ca-issuer)
  - apiVersion: cert-manager.io/v1
    kind: Certificate
    metadata:
      name: os-ca
    spec:
      isCA: true
      commonName: OpenSearch CA
      secretName: os-ca-certs
      privateKey:
        algorithm: RSA
        size: 2048
        encoding: PKCS8
        rotationPolicy: Always
      issuerRef:
        name: yig-ca-issuer
        kind: ClusterIssuer

  - apiVersion: cert-manager.io/v1
    kind: Issuer
    metadata:
      name: os-ca-issuer
    spec:
      ca:
        secretName: os-ca-certs

  # Admin client cert used by securityadmin.sh
  - apiVersion: cert-manager.io/v1
    kind: Certificate
    metadata:
      name: os-admin-certs
    spec:
      secretName: os-admin-certs
      issuerRef:
        name: os-ca-issuer
        kind: Issuer
      commonName: opensearch-admin
      usages: [client auth]
      privateKey:
        algorithm: RSA
        size: 2048
        encoding: PKCS8
        rotationPolicy: Always

  # Node cert (HTTP+transport). Include SANs that actually match what clients use.
  - apiVersion: cert-manager.io/v1
    kind: Certificate
    metadata:
      name: os-certs
    spec:
      secretName: os-certs
      issuerRef:
        name: os-ca-issuer
        kind: Issuer
      commonName: opensearch-nodes
      usages: [server auth, client auth]
      dnsNames:
        - ${cluster}-master
        - ${cluster}-master.${ns}.svc
        - ${cluster}-master.${ns}.svc.cluster.local
        - ${cluster}-master-0
        - ${cluster}-master-1
        - ${cluster}-master-2
      privateKey:
        algorithm: RSA
        size: 2048
        encoding: PKCS8
        rotationPolicy: Always

  # Traefik: skip upstream verification (matches your working pattern)
  - apiVersion: traefik.io/v1alpha1
    kind: ServersTransport
    metadata:
      name: opensearch-skip-verify
    spec:
      insecureSkipVerify: true

  - apiVersion: traefik.io/v1alpha1
    kind: IngressRoute
    metadata:
      name: opensearch-ui
    spec:
      entryPoints: [websecure]
      routes:
        - match: Host(`opensearch.${ingress_domain}`)
          kind: Rule
          services:
            - name: ${cluster}-master
              port: 9200
              scheme: https
              serversTransport: opensearch-skip-verify
      tls:
        secretName: opensearch-ui-tls

  - apiVersion: cert-manager.io/v1
    kind: Certificate
    metadata:
      name: opensearch-ui
    spec:
      secretName: opensearch-ui-tls
      dnsNames: ["opensearch.${ingress_domain}"]
      issuerRef:
        kind: ClusterIssuer
        name: yig-ca-issuer

  - apiVersion: v1
    kind: Secret
    metadata:
      name: securityconfig-secret
      namespace: ${ns}
    type: Opaque
    stringData:
      config.yml: |
        ---
        _meta:
          type: "config"
          config_version: "2"

        config:
          dynamic:
            http:
              anonymous_auth_enabled: false
              xff:
                enabled: true
                remoteIpHeader: "x-forwarded-for"
                internalProxies: "^10\\.244\\..*"

            authc:
              proxy_auth_domain:
                http_enabled: true
                transport_enabled: false
                order: 0
                http_authenticator:
                  type: proxy
                  challenge: false
                  config:
                    user_header: "remote-user"
                    roles_header: "remote-groups"
                    roles_separator: ","
                authentication_backend:
                  type: noop
              basic_internal_auth_domain:
                http_enabled: true
                transport_enabled: true
                order: 1
                http_authenticator:
                  type: basic
                  challenge: false
                authentication_backend:
                  type: intern

      roles_mapping.yml: |
        ---
        _meta:
          type: "rolesmapping"
          config_version: 2

        all_access:
          reserved: false
          backend_roles:
            - "${yig_ingress_admin_group}"
          users:
            - "admin"
          description: "Authelia admin group -> all_access"

        kibana_server:
          users:
            - "${opensearch_dashboards_user}"

      internal_users.yml: |
        ---
        _meta:
          type: "internalusers"
          config_version: 2

        ${opensearch_dashboards_user}:
          hash: "${opensearch_dashboards_password_bcrypt}"
          reserved: false
          description: "OpenSearch Dashboards server user"

        admin:
          hash: "${opensearch_admin_password_bcrypt}"
          reserved: false
          description: "Admin user"
      roles.yml: |
        ---
        _meta:
          type: "roles"
          config_version: 2
        all_access:
          reserved: false
          cluster_permissions:
            - "cluster_all"
          index_permissions:
            - index_patterns:
                - "*"
              allowed_actions:
                - "indices_all"
        kibana_server:
          reserved: false
          cluster_permissions:
            - "cluster:monitor/main"
            - "cluster:monitor/health"
            - "cluster:monitor/nodes/info"
          index_permissions:
            - index_patterns:
                - ".kibana"
                - ".kibana_*"
              allowed_actions:
                - "indices_all"
                - "system:admin/system_index"
        # below is dump from built-in roles
        kibana_read_only:
          reserved: true
        security_rest_api_access:
          reserved: true
        security_rest_api_full_access:
          reserved: true
          cluster_permissions:
          - "restapi:admin/actiongroups"
          - "restapi:admin/allowlist"
          - "restapi:admin/config/update"
          - "restapi:admin/internalusers"
          - "restapi:admin/nodesdn"
          - "restapi:admin/resource_sharing/migrate"
          - "restapi:admin/roles"
          - "restapi:admin/rolesmapping"
          - "restapi:admin/ssl/certs/info"
          - "restapi:admin/ssl/certs/reload"
          - "restapi:admin/tenants"
        alerting_read_access:
          reserved: true
          cluster_permissions:
          - "cluster:admin/opendistro/alerting/alerts/get"
          - "cluster:admin/opendistro/alerting/destination/get"
          - "cluster:admin/opendistro/alerting/monitor/get"
          - "cluster:admin/opendistro/alerting/monitor/search"
          - "cluster:admin/opensearch/alerting/comments/search"
          - "cluster:admin/opensearch/alerting/findings/get"
          - "cluster:admin/opensearch/alerting/remote/indexes/get"
          - "cluster:admin/opensearch/alerting/v2/alerts/get"
          - "cluster:admin/opensearch/alerting/v2/monitor/get"
          - "cluster:admin/opensearch/alerting/v2/monitor/search"
          - "cluster:admin/opensearch/alerting/workflow/get"
          - "cluster:admin/opensearch/alerting/workflow_alerts/get"
        alerting_ack_alerts:
          reserved: true
          cluster_permissions:
          - "cluster:admin/opendistro/alerting/alerts/*"
          - "cluster:admin/opendistro/alerting/chained_alerts/*"
          - "cluster:admin/opendistro/alerting/workflow_alerts/*"
          - "cluster:admin/opensearch/alerting/comments/*"
        alerting_full_access:
          reserved: true
          cluster_permissions:
          - "cluster:admin/opendistro/alerting/*"
          - "cluster:admin/opensearch/alerting/*"
          - "cluster:admin/opensearch/notifications/feature/publish"
          - "cluster_monitor"
          index_permissions:
          - index_patterns:
            - "*"
            allowed_actions:
            - "indices:admin/aliases/get"
            - "indices:admin/mappings/get"
            - "indices_monitor"
        anomaly_read_access:
          reserved: true
          cluster_permissions:
          - "cluster:admin/opendistro/ad/detector/info"
          - "cluster:admin/opendistro/ad/detector/search"
          - "cluster:admin/opendistro/ad/detector/suggest"
          - "cluster:admin/opendistro/ad/detector/validate"
          - "cluster:admin/opendistro/ad/detectors/get"
          - "cluster:admin/opendistro/ad/result/search"
          - "cluster:admin/opendistro/ad/result/topAnomalies"
          - "cluster:admin/opendistro/ad/tasks/search"
        anomaly_full_access:
          reserved: true
          cluster_permissions:
          - "cluster:admin/ingest/pipeline/delete"
          - "cluster:admin/ingest/pipeline/put"
          - "cluster:admin/opendistro/ad/*"
          - "cluster_monitor"
          index_permissions:
          - index_patterns:
            - "*"
            allowed_actions:
            - "indices:admin/aliases/get"
            - "indices:admin/mappings/fields/get"
            - "indices:admin/mappings/fields/get*"
            - "indices:admin/mappings/get"
            - "indices:admin/resolve/index"
            - "indices:admin/setting/put"
            - "indices:data/read/field_caps*"
            - "indices:data/read/search"
            - "indices_monitor"
        knn_read_access:
          reserved: true
          cluster_permissions:
          - "cluster:admin/knn_get_model_action"
          - "cluster:admin/knn_search_model_action"
          - "cluster:admin/knn_stats_action"
        knn_full_access:
          reserved: true
          cluster_permissions:
          - "cluster:admin/knn_delete_model_action"
          - "cluster:admin/knn_get_model_action"
          - "cluster:admin/knn_remove_model_from_cache_action"
          - "cluster:admin/knn_search_model_action"
          - "cluster:admin/knn_stats_action"
          - "cluster:admin/knn_training_job_route_decision_info_action"
          - "cluster:admin/knn_training_job_router_action"
          - "cluster:admin/knn_training_model_action"
          - "cluster:admin/knn_update_model_graveyard_action"
          - "cluster:admin/knn_warmup_action"
        ip2geo_datasource_read_access:
          reserved: true
          cluster_permissions:
          - "cluster:admin/geospatial/datasource/get"
        ip2geo_datasource_full_access:
          reserved: true
          cluster_permissions:
          - "cluster:admin/geospatial/datasource/*"
        notebooks_read_access:
          reserved: true
          cluster_permissions:
          - "cluster:admin/opendistro/notebooks/get"
          - "cluster:admin/opendistro/notebooks/list"
        notebooks_full_access:
          reserved: true
          cluster_permissions:
          - "cluster:admin/opendistro/notebooks/create"
          - "cluster:admin/opendistro/notebooks/delete"
          - "cluster:admin/opendistro/notebooks/get"
          - "cluster:admin/opendistro/notebooks/list"
          - "cluster:admin/opendistro/notebooks/update"
        observability_read_access:
          reserved: true
          cluster_permissions:
          - "cluster:admin/opensearch/observability/get"
        observability_full_access:
          reserved: true
          cluster_permissions:
          - "cluster:admin/opensearch/observability/create"
          - "cluster:admin/opensearch/observability/delete"
          - "cluster:admin/opensearch/observability/get"
          - "cluster:admin/opensearch/observability/update"
        ppl_full_access:
          reserved: true
          cluster_permissions:
          - "cluster:admin/opensearch/ppl"
          index_permissions:
          - index_patterns:
            - "*"
            allowed_actions:
            - "indices:admin/mappings/get"
            - "indices:data/read/search*"
            - "indices:monitor/settings/get"
        reports_instances_read_access:
          reserved: true
          cluster_permissions:
          - "cluster:admin/opendistro/reports/instance/get"
          - "cluster:admin/opendistro/reports/instance/list"
          - "cluster:admin/opendistro/reports/menu/download"
        reports_read_access:
          reserved: true
          cluster_permissions:
          - "cluster:admin/opendistro/reports/definition/get"
          - "cluster:admin/opendistro/reports/definition/list"
          - "cluster:admin/opendistro/reports/instance/get"
          - "cluster:admin/opendistro/reports/instance/list"
          - "cluster:admin/opendistro/reports/menu/download"
        reports_full_access:
          reserved: true
          cluster_permissions:
          - "cluster:admin/opendistro/reports/definition/create"
          - "cluster:admin/opendistro/reports/definition/delete"
          - "cluster:admin/opendistro/reports/definition/get"
          - "cluster:admin/opendistro/reports/definition/list"
          - "cluster:admin/opendistro/reports/definition/on_demand"
          - "cluster:admin/opendistro/reports/definition/update"
          - "cluster:admin/opendistro/reports/instance/get"
          - "cluster:admin/opendistro/reports/instance/list"
          - "cluster:admin/opendistro/reports/menu/download"
        asynchronous_search_full_access:
          reserved: true
          cluster_permissions:
          - "cluster:admin/opendistro/asynchronous_search/*"
          index_permissions:
          - index_patterns:
            - "*"
            allowed_actions:
            - "indices:data/read/search*"
        asynchronous_search_read_access:
          reserved: true
          cluster_permissions:
          - "cluster:admin/opendistro/asynchronous_search/get"
        index_management_full_access:
          reserved: true
          cluster_permissions:
          - "cluster:admin/opendistro/ism/*"
          - "cluster:admin/opendistro/rollup/*"
          - "cluster:admin/opendistro/transform/*"
          - "cluster:admin/opensearch/controlcenter/lron/*"
          - "cluster:admin/opensearch/notifications/channels/get"
          - "cluster:admin/opensearch/notifications/feature/publish"
          index_permissions:
          - index_patterns:
            - "*"
            allowed_actions:
            - "indices:admin/opensearch/ism/*"
            - "indices:internal/plugins/replication/index/stop"
        cross_cluster_replication_leader_full_access:
          reserved: true
          index_permissions:
          - index_patterns:
            - "*"
            allowed_actions:
            - "indices:admin/plugins/replication/index/setup/validate"
            - "indices:data/read/plugins/replication/changes"
            - "indices:data/read/plugins/replication/file_chunk"
        cross_cluster_replication_follower_full_access:
          reserved: true
          cluster_permissions:
          - "cluster:admin/plugins/replication/autofollow/update"
          index_permissions:
          - index_patterns:
            - "*"
            allowed_actions:
            - "indices:admin/plugins/replication/index/pause"
            - "indices:admin/plugins/replication/index/resume"
            - "indices:admin/plugins/replication/index/setup/validate"
            - "indices:admin/plugins/replication/index/start"
            - "indices:admin/plugins/replication/index/status_check"
            - "indices:admin/plugins/replication/index/stop"
            - "indices:admin/plugins/replication/index/update"
            - "indices:data/write/plugins/replication/changes"
        cross_cluster_search_remote_full_access:
          reserved: true
          index_permissions:
          - index_patterns:
            - "*"
            allowed_actions:
            - "indices:admin/shards/search_shards"
            - "indices:data/read/search"
        query_assistant_access:
          reserved: true
          cluster_permissions:
          - "cluster:admin/opensearch/ml/config/get"
          - "cluster:admin/opensearch/ml/execute"
          - "cluster:admin/opensearch/ml/predict"
          - "cluster:admin/opensearch/ppl"
        ml_read_access:
          reserved: true
          cluster_permissions:
          - "cluster:admin/opensearch/ml/config/get"
          - "cluster:admin/opensearch/ml/connectors/get"
          - "cluster:admin/opensearch/ml/connectors/search"
          - "cluster:admin/opensearch/ml/controllers/get"
          - "cluster:admin/opensearch/ml/memory/conversation/get"
          - "cluster:admin/opensearch/ml/memory/conversation/interaction/search"
          - "cluster:admin/opensearch/ml/memory/conversation/list"
          - "cluster:admin/opensearch/ml/memory/conversation/search"
          - "cluster:admin/opensearch/ml/memory/interaction/get"
          - "cluster:admin/opensearch/ml/memory/interaction/list"
          - "cluster:admin/opensearch/ml/memory/trace/get"
          - "cluster:admin/opensearch/ml/model_groups/get"
          - "cluster:admin/opensearch/ml/model_groups/search"
          - "cluster:admin/opensearch/ml/models/get"
          - "cluster:admin/opensearch/ml/models/search"
          - "cluster:admin/opensearch/ml/profile/nodes"
          - "cluster:admin/opensearch/ml/stats/nodes"
          - "cluster:admin/opensearch/ml/tasks/get"
          - "cluster:admin/opensearch/ml/tasks/search"
          - "cluster:admin/opensearch/ml/to`ols/get"
          - "cluster:admin/opensearch/ml/tools/list"
        ml_full_access:
          reserved: true
          cluster_permissions:
          - "cluster:admin/opensearch/ml/*"
          - "cluster_monitor"
          index_permissions:
          - index_patterns:
            - "*"
            allowed_actions:
            - "indices_monitor"
        notifications_full_access:
          reserved: true
          cluster_permissions:
          - "cluster:admin/opensearch/notifications/*"
        notifications_read_access:
          reserved: true
          cluster_permissions:
          - "cluster:admin/opensearch/notifications/channels/get"
          - "cluster:admin/opensearch/notifications/configs/get"
          - "cluster:admin/opensearch/notifications/features"
        snapshot_management_full_access:
          reserved: true
          cluster_permissions:
          - "cluster:admin/opensearch/notifications/feature/publish"
          - "cluster:admin/opensearch/snapshot_management/*"
          - "cluster:admin/repository/*"
          - "cluster:admin/snapshot/*"
        snapshot_management_read_access:
          reserved: true
          cluster_permissions:
          - "cluster:admin/opensearch/snapshot_management/policy/explain"
          - "cluster:admin/opensearch/snapshot_management/policy/get"
          - "cluster:admin/opensearch/snapshot_management/policy/search"
          - "cluster:admin/repository/get"
          - "cluster:admin/snapshot/get"
        point_in_time_full_access:
          reserved: true
          index_permissions:
          - index_patterns:
            - "*"
            allowed_actions:
            - "manage_point_in_time"
        security_analytics_read_access:
          reserved: true
          cluster_permissions:
          - "cluster:admin/opensearch/securityanalytics/alerts/get"
          - "cluster:admin/opensearch/securityanalytics/correlationAlerts/get"
          - "cluster:admin/opensearch/securityanalytics/correlations/findings"
          - "cluster:admin/opensearch/securityanalytics/correlations/list"
          - "cluster:admin/opensearch/securityanalytics/detector/get"
          - "cluster:admin/opensearch/securityanalytics/detector/search"
          - "cluster:admin/opensearch/securityanalytics/findings/get"
          - "cluster:admin/opensearch/securityanalytics/logtype/search"
          - "cluster:admin/opensearch/securityanalytics/mapping/get"
          - "cluster:admin/opensearch/securityanalytics/mapping/view/get"
          - "cluster:admin/opensearch/securityanalytics/rule/get"
          - "cluster:admin/opensearch/securityanalytics/rule/search"
          - "cluster:admin/opensearch/securityanalytics/threatintel/alerts/get"
          - "cluster:admin/opensearch/securityanalytics/threatintel/iocs/findings/get"
          - "cluster:admin/opensearch/securityanalytics/threatintel/iocs/list"
          - "cluster:admin/opensearch/securityanalytics/threatintel/monitors/search"
          - "cluster:admin/opensearch/securityanalytics/threatintel/sources/get"
          - "cluster:admin/opensearch/securityanalytics/threatintel/sources/search"
        security_analytics_full_access:
          reserved: true
          cluster_permissions:
          - "cluster:admin/opensearch/securityanalytics/alerts/*"
          - "cluster:admin/opensearch/securityanalytics/connections/*"
          - "cluster:admin/opensearch/securityanalytics/correlationAlerts/*"
          - "cluster:admin/opensearch/securityanalytics/correlations/*"
          - "cluster:admin/opensearch/securityanalytics/detector/*"
          - "cluster:admin/opensearch/securityanalytics/findings/*"
          - "cluster:admin/opensearch/securityanalytics/logtype/*"
          - "cluster:admin/opensearch/securityanalytics/mapping/*"
          - "cluster:admin/opensearch/securityanalytics/rule/*"
          - "cluster:admin/opensearch/securityanalytics/threatintel/*"
          index_permissions:
          - index_patterns:
            - "*"
            allowed_actions:
            - "indices:admin/mapping/put"
            - "indices:admin/mappings/get"
        security_analytics_ack_alerts:
          reserved: true
          cluster_permissions:
          - "cluster:admin/opensearch/securityanalytics/alerts/*"
          - "cluster:admin/opensearch/securityanalytics/correlationAlerts/*"
          - "cluster:admin/opensearch/securityanalytics/threatintel/alerts/*"
        flow_framework_full_access:
          reserved: true
          cluster_permissions:
          - "cluster:admin/opensearch/flow_framework/*"
          - "cluster_monitor"
          index_permissions:
          - index_patterns:
            - "*"
            allowed_actions:
            - "indices:admin/aliases/get"
            - "indices:admin/mappings/get"
            - "indices_monitor"
        flow_framework_read_access:
          reserved: true
          cluster_permissions:
          - "cluster:admin/opensearch/flow_framework/workflow/get"
          - "cluster:admin/opensearch/flow_framework/workflow/search"
          - "cluster:admin/opensearch/flow_framework/workflow_state/get"
          - "cluster:admin/opensearch/flow_framework/workflow_state/search"
          - "cluster:admin/opensearch/flow_framework/workflow_step/get"
        query_insights_full_access:
          reserved: true
          cluster_permissions:
          - "cluster:admin/opensearch/insights/*"
          index_permissions:
          - index_patterns:
            - "top_queries-*"
            allowed_actions:
            - "indices_all"
        ltr_read_access:
          reserved: true
          cluster_permissions:
          - "cluster:admin/ltr/caches/stats"
          - "cluster:admin/ltr/featurestore/list"
          - "cluster:admin/ltr/stats"
        ltr_full_access:
          reserved: true
          cluster_permissions:
          - "cluster:admin/ltr/*"
        search_relevance_full_access:
          reserved: true
          cluster_permissions:
          - "cluster:admin/opensearch/search_relevance/*"
          index_permissions:
          - index_patterns:
            - "*"
            allowed_actions:
            - "indices:admin/mappings/get"
            - "indices:data/read/*"
        search_relevance_read_access:
          reserved: true
          cluster_permissions:
          - "cluster:admin/opensearch/search_relevance/experiment/get"
          - "cluster:admin/opensearch/search_relevance/judgment/get"
          - "cluster:admin/opensearch/search_relevance/queryset/get"
          - "cluster:admin/opensearch/search_relevance/search_configuration/get"
          index_permissions:
          - index_patterns:
            - "search-relevance-*"
            allowed_actions:
            - "indices:admin/mappings/get"
            - "indices:data/read/*"
        forecast_read_access:
          reserved: true
          cluster_permissions:
          - "cluster:admin/plugin/forecast/forecaster/info"
          - "cluster:admin/plugin/forecast/forecaster/stats"
          - "cluster:admin/plugin/forecast/forecaster/suggest"
          - "cluster:admin/plugin/forecast/forecaster/validate"
          - "cluster:admin/plugin/forecast/forecasters/get"
          - "cluster:admin/plugin/forecast/forecasters/info"
          - "cluster:admin/plugin/forecast/forecasters/search"
          - "cluster:admin/plugin/forecast/result/topForecasts"
          - "cluster:admin/plugin/forecast/tasks/search"
          index_permissions:
          - index_patterns:
            - "opensearch-forecast-result*"
            allowed_actions:
            - "indices:admin/mappings/fields/get*"
            - "indices:admin/resolve/index"
            - "indices:data/read*"
        forecast_full_access:
          reserved: true
          cluster_permissions:
          - "cluster:admin/plugin/forecast/*"
          - "cluster:admin/settings/update"
          - "cluster_monitor"
          index_permissions:
          - index_patterns:
            - "*"
            allowed_actions:
            - "indices:admin/aliases/get"
            - "indices:admin/mapping/get"
            - "indices:admin/mapping/put"
            - "indices:admin/mappings/fields/get*"
            - "indices:admin/mappings/get"
            - "indices:admin/resolve/index"
            - "indices:data/read*"
            - "indices:data/read/field_caps*"
            - "indices:data/read/search"
            - "indices:data/write*"
            - "indices_monitor"