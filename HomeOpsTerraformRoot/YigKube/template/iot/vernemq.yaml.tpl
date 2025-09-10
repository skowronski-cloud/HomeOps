---
# https://github.com/vernemq/docker-vernemq/blob/master/helm/vernemq/values.yaml

image:
  repository: 11notes/vernemq # NOTE: https://github.com/vernemq/docker-vernemq/issues/411
  tag: ${ docker_image_tag }

securityContext: # 10k is on vendor,m 1k is on 11notes/vernemq
  runAsUser: 1000
  runAsGroup: 1000
  fsGroup: 1000

additionalEnv:
  - name: DOCKER_VERNEMQ_DISCOVERY_KUBERNETES
    value: "1"
  - name: MY_POD_NAME
    valueFrom:
      fieldRef:
        fieldPath: metadata.name
  - name: DOCKER_VERNEMQ_KUBERNETES_LABEL_SELECTOR
    value: "app=vernemq"

#  # vendor
#  - name: DOCKER_VERNEMQ_ALLOW_REGISTER_DURING_NETSPLIT
#    value: "on"
#  - name: DOCKER_VERNEMQ_ALLOW_PUBLISH_DURING_NETSPLIT
#    value: "on"
#  - name: DOCKER_VERNEMQ_ALLOW_SUBSCRIBE_DURING_NETSPLIT
#    value: "on"
#  - name: DOCKER_VERNEMQ_ALLOW_UNSUBSCRIBE_DURING_NETSPLIT
#    value: "on"
#  # user
#  - name: DOCKER_VERNEMQ_DISCOVERY__KUBERNETES
#    value: "1"
#  - name: DOCKER_VERNEMQ_KUBERNETES__APP_LABEL
#    value: "app.kubernetes.io/name=vernemq"
#  - name: DOCKER_VERNEMQ_KUBERNETES__NAMESPACE
#    value: ${ ns }
#  - name: DOCKER_VERNEMQ_ALLOW__ANONYMOUS
#    value: "off"
#  - name: DOCKER_VERNEMQ_PLUGINS__VMQ__DIVERSITY
#    value: "off"
#  - name: DOCKER_VERNEMQ_PLUGINS__VMQ__PASSWD
#    value: "on"
#  - name: DOCKER_VERNEMQ_PLUGINS__VMQ__ACL
#    value: "on"
#  - name: DOCKER_VERNEMQ_CONF__VMQ_PASSWD__PASSWORD_RELOAD_INTERVAL
#    value: 30s
#  - name: DOCKER_VERNEMQ_CONF__VMQ_ACL__ACL_RELOAD_INTERVAL
#    value: 30s
#  ## avoid issues with volume projection
#  #- name: DOCKER_VERNEMQ_CONF__VMQ_PASSWD__PASSWORD_FILE 
#  #  value: /etc/vernemq/passwords/vmq.passwd
#  - name: DOCKER_VERNEMQ_CONF__VMQ_ACL__ACL_FILE
#    value: /etc/vernemq/acl/vmq.acl
envFrom:
  - secretRef:
      name: vernemq-env
  - secretRef:
      name: vernemq-passwd

extraVolumeMounts:
#  - name: vmq-passwd
#    mountPath: /etc/vernemq/passwords
  - name: vmq-acl
    mountPath: /etc/vernemq/acl
  - name: vernemq-etc
    mountPath: /etc/vernemq/vernemq.conf #.local
    subPath: vernemq.conf #.local
extraVolumes:
#  - name: vmq-passwd
#    configMap:
#      name: vernemq-vmq-passwd
  - name: vmq-acl
    secret:
      secretName: vernemq-vmq-acl
  - name: vernemq-etc
    secret:
      secretName: vernemq-etc
podAntiAffinity: ${ highlyAvailableServiceConfig.affinityPreset }
replicaCount: ${ highlyAvailableServiceConfig.replicaCount }
service:
  mqtt:
    enabled: true
    port: 1883
serviceMonitor:
  create: true
  labels:
    release: ${ metrics_label_release }
acl:
  enabled: false # managed via configmap for hot-reload

