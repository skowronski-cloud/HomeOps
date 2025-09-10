---
# https://artifacthub.io/packages/helm/k8s-home-lab-repo/home-assistant?modal=values
ingress:
  enabled: true
  hosts:
    - host: ${ fqdn }
      paths:
        - path: /
          pathType: ImplementationSpecific
additionalVolumes:
  - name: secrets-yaml
    secret:
      secretName: secrets-yaml
      items:
        - key: secrets-yaml
          path: secrets.yaml
  - name: mqtt-yaml
    secret:
      secretName: mqtt-yaml
      items:
        - key: mqtt-yaml
          path: mqtt.yaml
additionalMounts:
  - name: secrets-yaml
    mountPath: /config/secrets.yaml
    subPath: secrets.yaml
  - name: mqtt-yaml
    mountPath: /config/info_mqtt.yaml
    subPath: mqtt.yaml
configuration:
  enabled: true
  forceInit: true
  trusted_proxies:
    - 10.0.0.0/8
  templateConfig: |-
    # Loads default set of integrations. Do not remove.
    default_config:

    logger:
      default: DEBUG

    http:
      use_x_forwarded_for: true
      trusted_proxies:
        - 10.0.0.0/8
    
    # Load frontend themes from the themes folder
    frontend:
      themes: !include_dir_merge_named themes

    recorder: 
      db_url: !secret psql_string
      #auto_purge: false
      db_retry_wait: 15 # Wait 15 seconds before retrying
      purge_keep_days: 3650 # 10y
      exclude:
        domains:
          - automation
          - updater
        entity_globs: []
        entities:
          - sun.sun
          - sensor.last_boot
          - sensor.date
        event_types:
          - call_service # Don't record service calls

    automation: !include automations.yaml
    script: !include scripts.yaml
    scene: !include scenes.yaml

    # mqtt: !include mqtt.yaml # HA doesn't like YAML for MQTT broker anymore ;______;

    prometheus:
      filter:
        include_entity_globs:
            - event.backup_automatic_backup
            - sensor.backup_*
            - sensor.ups_*
      requires_auth: false
resources:
  requests:
    memory: 1Gi
    cpu: 250m
  limits: {}