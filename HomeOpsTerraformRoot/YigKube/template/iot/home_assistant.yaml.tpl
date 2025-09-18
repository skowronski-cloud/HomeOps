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
  - name: ha-cfg
    secret:
      secretName: ha-cfg
additionalMounts:
  - name: secrets-yaml
    mountPath: /config/secrets.yaml
    subPath: secrets.yaml
  - name: ha-cfg
    mountPath: /config/cfg/
configuration:
  enabled: true
  forceInit: true
  trusted_proxies:
    - 10.0.0.0/8
  templateConfig: |-
    # Loads default set of integrations. Do not remove.
    default_config:

    logger: !include cfg/logger.yaml

    http:
      use_x_forwarded_for: true
      trusted_proxies:
        - 10.0.0.0/8
    
    # Load frontend themes from the themes folder
    frontend:
      themes: !include_dir_merge_named themes

    recorder: !include cfg/recorder.yaml

    automation: !include cfg/automations.yaml
    script: !include cfg/scripts.yaml
    scene: !include cfg/scenes.yaml

    mqtt: !include cfg/mqtt.yaml

    prometheus: !include cfg/prometheus.yaml
resources:
  requests:
    memory: 1Gi
    cpu: 250m
  limits: {}