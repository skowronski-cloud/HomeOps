---
CustomResources:
  - name: victoria-logs-vlagent
    fullnameOverride: victoria-logs-vlagent
    apiVersion: operator.victoriametrics.com/v1
    kind: VLAgent
    spec:
      image:
        repository: victoriametrics/vlagent
        tag: ${vlagent_version}
        pullPolicy: IfNotPresent
      logFormat: json
      logLevel: INFO
      k8sCollector:
        enabled: true
        checkpointsPath: /var/lib/vlagent-data/checkpoints.json
        excludeFilter: 'kubernetes.pod_name:=%%{HOSTNAME}'
        extraFields: '{"cluster":${jsonencode(vlagent_cluster_name)}}'
        includePodLabels: true
        includePodAnnotations: false
        includeNodeLabels: true
        includeNodeAnnotations: false
      extraArgs:
        envflag.enable: "true"
      remoteWrite:
        - url: https://${service_name}.logging.svc.cluster.local:${api_port}/insert/native
          basicAuth:
            username:
              name: ${auth_secret_name}
              key: writer_username
            password:
              name: ${auth_secret_name}
              key: writer_password
          tlsConfig:
            caSecretKeyRef:
              name: ${ca_secret_name}
              key: ca.crt
            serverName: ${service_name}.logging.svc.cluster.local
          maxDiskUsage: ${vlagent_max_disk_usage}
      remoteWriteSettings:
        maxDiskUsagePerURL: ${vlagent_max_disk_usage}
        tmpDataPath: /var/lib/vlagent-data/remote-write
      tmpDataPath: /var/lib/vlagent-data
      podMetadata:
        annotations:
          prometheus.io/scrape: "true"
          prometheus.io/path: /metrics
          prometheus.io/port: "9429"
      resources:
        requests:
          cpu: ${vlagent_cpu_request}
          memory: ${vlagent_memory_request}
        limits:
          cpu: ${vlagent_cpu_limit}
          memory: ${vlagent_memory_limit}
      tolerations:
        - operator: Exists
      volumes:
        - name: vlagent-data
          hostPath:
            path: /var/lib/vlagent-data
            type: DirectoryOrCreate
      volumeMounts:
        - name: vlagent-data
          mountPath: /var/lib/vlagent-data

  - name: victoria-logs-transport
    fullnameOverride: victoria-logs
    apiVersion: traefik.io/v1alpha1
    kind: ServersTransport
    spec:
      serverName: ${service_name}.logging.svc.cluster.local
      rootCAsSecrets:
        - ${ca_secret_name}
      forwardingTimeouts:
        dialTimeout: 10s
        responseHeaderTimeout: 60s

  - name: victoria-logs-ui-auth
    fullnameOverride: victoria-logs-ui-auth
    apiVersion: traefik.io/v1alpha1
    kind: Middleware
    spec:
      headers:
        customRequestHeaders:
          X-VL-Auth: ${ingress_proxy_auth_header}

  - name: victoria-logs-ui-root
    fullnameOverride: victoria-logs-ui-root
    apiVersion: traefik.io/v1alpha1
    kind: Middleware
    spec:
      redirectRegex:
        regex: '^https?://[^/]+/?$'
        replacement: 'https://victoria-logs.${ingress_domain}/select/vmui/'
        permanent: false

  - name: victoria-logs-ingress
    fullnameOverride: victoria-logs
    apiVersion: traefik.io/v1alpha1
    kind: IngressRoute
    annotations:
      gethomepage.dev/enabled: "true"
      gethomepage.dev/name: VictoriaLogs
      gethomepage.dev/icon: sh-victoriametrics
      gethomepage.dev/group: Monitoring
    spec:
      entryPoints:
        - websecure
      routes:
        - match: Host(`victoria-logs.${ingress_domain}`)
          kind: Rule
          middlewares:
            - name: victoria-logs-ui-root
            - name: victoria-logs-ui-auth
          services:
            - name: ${service_name}
              port: ${api_port}
              scheme: https
              serversTransport: victoria-logs
              passHostHeader: true
      tls: {}

  - name: victoria-logs-metrics
    fullnameOverride: victoria-logs
    apiVersion: operator.victoriametrics.com/v1beta1
    kind: VMStaticScrape
    extraLabels:
      app.kubernetes.io/part-of: victoria-logs
    spec:
      jobName: victoria-logs
      targetEndpoints:
        - targets:
            - ${service_name}.logging.svc.cluster.local:${api_port}
          path: /internal/metrics
          scheme: https
          scrape_interval: 30s
          basicAuth:
            username:
              name: ${auth_secret_name}
              key: reader_username
            password:
              name: ${auth_secret_name}
              key: reader_password
          tlsConfig:
            ca:
              secret:
                name: ${ca_secret_name}
                key: ca.crt
            serverName: ${service_name}.logging.svc.cluster.local
