---
# https://artifacthub.io/packages/helm/opensearch-project-helm-charts/opensearch-dashboards?modal=values
# https://github.com/opensearch-project/OpenSearch-Dashboards/blob/main/config/opensearch_dashboards.yml

opensearchHosts: "https://${cluster}-master.${ns}.svc:9200"
config:
  opensearch_dashboards.yml: |
    opensearch.ssl.verificationMode: none
    opensearchDashboards.index: ".kibana"

    opensearch.requestHeadersAllowlist: ["remote-user","remote-groups","remote-email","x-forwarded-for","x-forwarded-proto","x-forwarded-host"]

    opensearch.username: "${opensearch_dashboards_user}"
    opensearch.password: "${opensearch_dashboards_password}"

    opensearch_security.auth.type: "proxy"
    opensearch_security.proxycache.user_header: "remote-user"
    opensearch_security.proxycache.roles_header: "remote-groups"

resources:
  limits:
    cpu: 500m
    memory: 2Gi
  requests:
    cpu: 250m
    memory: 1Gi

startupProbe:
  enabled: false
livenessProbe:
  enabled: false

ingress:
  enabled: true
  annotations:
    gethomepage.dev/enabled: "true"
    gethomepage.dev/name: "OpenSearch Dashboards"
    gethomepage.dev/icon: sh-opensearch
    gethomepage.dev/group: "Monitoring"
    gethomepage.dev/external: "true"
  labels: {}
  hosts:
    - host: osd.${ingress_domain}
      paths:
        - path: /
          backend:
            serviceName: ""
            servicePort: ""
