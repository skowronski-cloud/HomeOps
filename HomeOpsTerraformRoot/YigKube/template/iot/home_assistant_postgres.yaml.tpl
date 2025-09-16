---
# https://artifacthub.io/packages/helm/bitnami/postgresql-ha?modal=values
global:
  postgresql:
    database: ha
    username: ha
    existingSecret: ${ instance_name }-postgresql
  pgpool:
    existingSecret: ${ instance_name }-postgresql
persistence:
  enabled: true
  size: ${ volume_size }

postgresql:
  replicaCount: ${xasc.replicaCount}
  podAntiAffinityPreset: ${xasc.affinityPreset}
  updateStrategy:
    type: ${xasc.updateStrategy.type}
    rollingUpdate:
      maxSurge: ${xasc.updateStrategy.rollingUpdate.maxSurge}
      maxUnavailable: ${xasc.updateStrategy.rollingUpdate.maxUnavailable}
  resources:
    requests:
      memory: 512Mi
      cpu: 200m
    limits: {}
pgpool:
  replicaCount: ${xasc.replicaCount}
  podAntiAffinityPreset: ${xasc.affinityPreset}
  updateStrategy:
    type: ${xasc.updateStrategy.type}
    rollingUpdate:
      maxSurge: ${xasc.updateStrategy.rollingUpdate.maxSurge}
      maxUnavailable: ${xasc.updateStrategy.rollingUpdate.maxUnavailable}
  resources:
    requests:
      memory: 256Mi
      cpu: 100m
    limits: {}
