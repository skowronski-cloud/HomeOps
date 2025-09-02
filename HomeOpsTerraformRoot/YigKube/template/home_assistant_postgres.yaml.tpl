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
  replicaCount: ${highlyAvailableServiceConfig.replicaCount}
  podAntiAffinityPreset: ${highlyAvailableServiceConfig.affinityPreset}
  updateStrategy:
    type: ${highlyAvailableServiceConfig.updateStrategy.type}
    rollingUpdate:
      maxSurge: ${highlyAvailableServiceConfig.updateStrategy.rollingUpdate.maxSurge}
      maxUnavailable: ${highlyAvailableServiceConfig.updateStrategy.rollingUpdate.maxUnavailable}
  resources:
    requests:
      memory: 512Mi
      cpu: 200m
    limits: {}
pgpool:
  replicaCount: ${highlyAvailableServiceConfig.replicaCount}
  podAntiAffinityPreset: ${highlyAvailableServiceConfig.affinityPreset}
  updateStrategy:
    type: ${highlyAvailableServiceConfig.updateStrategy.type}
    rollingUpdate:
      maxSurge: ${highlyAvailableServiceConfig.updateStrategy.rollingUpdate.maxSurge}
      maxUnavailable: ${highlyAvailableServiceConfig.updateStrategy.rollingUpdate.maxUnavailable}
  resources:
    requests:
      memory: 256Mi
      cpu: 100m
    limits: {}
