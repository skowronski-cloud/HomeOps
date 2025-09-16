---
# https://artifacthub.io/packages/helm/traefik/traefik?modal=values
logs:
  general:
    level: INFO
providers:
  kubernetesCRD:
    allowExternalNameServices: true
  kubernetesIngress:
    allowExternalNameServices: true
volumes:
  - name: ${ ca_crt_secret }
    mountPath: /etc/pki/tls/certs # https://go.dev/src/crypto/x509/root_linux.go - purposefully other dir than OS-default
    type: secret
deployment:
  replicas: ${xasc.replicaCount}
  terminationGracePeriodSeconds: 0
  minReadySeconds: 30

additionalArguments:
  #- --entryPoints.websecure.http.middlewares=traefik-system-forwardauth-authelia@kubernetescrd
  - --serversTransport.rootCAs=/etc/pki/tls/certs/ca.crt

tolerations:
  - key: node.kubernetes.io/not-ready
    operator: Exists
    effect: NoExecute
    tolerationSeconds: 15
  - key: node.kubernetes.io/unreachable
    operator: Exists
    effect: NoExecute
    tolerationSeconds: 15


affinity:
  podAntiAffinity:
    %{if xasc.affinityPreset=="hard"}required%{else}preferred%{endif}DuringSchedulingIgnoredDuringExecution:
      - labelSelector:
          matchLabels:
            app.kubernetes.io/name: '{{ template "traefik.name" . }}'
            app.kubernetes.io/instance: '{{ .Release.Name }}-{{ include "traefik.namespace" . }}'
        topologyKey: kubernetes.io/hostname

updateStrategy:
  type: ${xasc.updateStrategy.type}
  rollingUpdate:
    maxUnavailable: ${xasc.updateStrategy.rollingUpdate.maxUnavailable}
    maxSurge: ${xasc.updateStrategy.rollingUpdate.maxSurge}

resources:
  requests:
    memory: 50Mi
    cpu: 100m
  limits: {}

metrics:
  prometheus:
    service:
      enabled: true
      labels:
        release: ${metrics_label_release}
    serviceMonitor:
      enabled: true
      additionalLabels:
        release: ${metrics_label_release}
    prometheusRule:
      enabled: false
      additionalLabels:
        release: ${metrics_label_release}

ingressRoute:
  healthcheck:
    enabled: true
    #middlewares:
    #  - "traefik-system-forwardauth-authelia@kubernetescrd"

ports:
  websecure:
    middlewares:
      - "traefik-system-forwardauth-authelia@kubernetescrd"