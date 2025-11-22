---
replicaCount:  ${xasc.replicaCount}

emqxConfig:
  node.name: "emqx@$(POD_NAME).emqx.home-assistant.svc.cluster.local"
  cluster.discovery: "k8s"

persistence:
  enabled: true

resources:
  requests:
    cpu: 500m
    memory: 512Mi
  limits: {}

ingress:
  dashboard:
    enabled: true
    hosts:
      - emqx-dashboard.${ingress_domain}
    annotations:
      gethomepage.dev/enabled: "true"
      gethomepage.dev/name: "EQMX"
      gethomepage.dev/icon: sh-emqx
      gethomepage.dev/group: "Admin"
      gethomepage.dev/external: "true"
metrics:
  enabled: true

service:
  type: LoadBalancer
  labels: # FIXME: chart applies same labels to service and servicemonitor which is incorrect!
    release: ${metrics_label_release}

ssl:
  enabled: true
  commonName: mqtt.${ingress_domain}
  dnsnames:
    - emqx.${ingress_domain}
  issuer:
    name: yig-ca-issuer
    kind: ClusterIssuer

extraVolumes:
  - name: emqx-cfg
    secret: 
      secretName: emqx-cfg
extraVolumeMounts:
  - name: emqx-cfg
    mountPath: /opt/emqx/etc/acl.conf
    subPath: acl.conf
  - name: emqx-cfg
    mountPath: /opt/emqx/etc/default_api_key.conf
    subPath: default_api_key.conf

emqxConfig:
  EMQX_DASHBOARD__DEFAULT_PASSWORD: ${emqx_dashboard_password}
  api_key.bootstrap_file: /opt/emqx/etc/default_api_key.conf

  authentication.1.mechanism: password_based
  authentication.1.backend: built_in_database
  authentication.1.enable: "true"
  
  authorization.sources.1.type: built_in_database
  authorization.sources.1.enable: "true"
  authorization.sources.2.type: file
  authorization.sources.2.enable: "true"
  authorization.sources.2.path: /opt/emqx/etc/acl.conf