---
# https://artifacthub.io/packages/helm/victoriametrics/victoria-metrics-k8s-stack?modal=values
external:
  grafana:
    host: grafana.${ingress_domain}
vmsingle:
  enabled: false
vmauth:
  enabled: true
  spec:
    unauthorizedUserAccessSpec: {}
    selectAllByDefault: true
    userNamespaceSelector: {}
    userSelector: {}
global:
  cluster:
    dnsDomain: cluster.local  # https://github.com/golang/go/issues/75861
victoria-metrics-operator:
  admissionWebhooks:
    enabled: true
    certManager:
      enabled: true
      issuer:
        name: yig-ca-issuer
        kind: ClusterIssuer

# FIXME: network policies!
