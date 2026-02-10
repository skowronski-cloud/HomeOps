---
# https://artifacthub.io/packages/helm/netbox/netbox?modal=values
image:
  repository: ghcr.io/danielskowronski/custom-netbox-docker-with-plugins
  tag: "${ ver_docker_netbox_custom }"
  pullPolicy: IfNotPresent
superuser:
  existingSecret: netbox-secrets
dataUploadMaxMemorySize: 134217728 # 128 MiB
fileUploadMaxMemorySize: 134217728 # 128 MiB
dbWaitDebug: true
loginRequired: true
paginateCount: 100
timeZone: "UTC"
preferIPv4: true
pluginsConfig: {}

livenessProbe:
  enabled: false # https://github.com/netbox-community/netbox-chart/issues/1032#issuecomment-3856265309

remoteAuth:
  enabled: true
  backends:
    - netbox.authentication.LDAPBackend
  ldap:
    serverUri: ${ ldap_url }
    ignoreCertErrors: true # FIXME
    bindDn: ${ ldap_user }
    userSearchBaseDn: ${ ldap_basedn }
    requireGroupDn:
      - CN=${ admin_group },CN=Users,${ ldap_basedn }
    isSuperUserDn:
      - CN=${ admin_group },CN=Users,${ ldap_basedn }

persistence:
  enabled: true
  size: 16Gi

ingress:
  enabled: true
  annotations:
    gethomepage.dev/enabled: "true"
    gethomepage.dev/name: "NetBox"
    gethomepage.dev/icon: sh-netbox
    gethomepage.dev/group: "Mgmt"
    gethomepage.dev/external: "true"
  hosts:
    - host: netbox.${ ingress_domain }
      paths:
        - /

resources:
  requests:
    cpu: 2
    memory: 1024Mi
  limits:
    cpu: 99
    memory: 4096Mi

plugins:
  - netbox_lists
  - netbox_lifecycle
  - netbox_documents
  - netbox_attachments
  - netbox_topology_views
  - netbox_qrcode
  - netbox_dns
  - netbox_bgp

valkey:
  global:
    valkey:
      password: ${ valkey_password }
postgresql:
  # FIXME: use externally managed DB with HA
  enabled: true
  global:
    postgresql:
      auth:
        password: ${ postgres_password }
