---
# https://artifacthub.io/packages/helm/prometheus-community/prometheus-blackbox-exporter?modal=values
# https://github.com/prometheus/blackbox_exporter/blob/master/example.yml

podSecurityContext:
   sysctls:
     - name: net.ipv4.ping_group_range
       value: "0 2147483647"

ingress:
  enabled: true
  ingressClassName: "traefik"
  annotations: []
  hosts:
    - host: blackbox.${ingress_domain}
      paths:
        - path: /
          pathType: ImplementationSpecific

config:
  modules:
    http_2xx:
      prober: http
      timeout: 5s
      http:
        valid_http_versions: ["HTTP/1.1", "HTTP/2.0"]
        follow_redirects: true
        preferred_ip_protocol: "ip4"
    icmp:
      prober: icmp
      timeout: 5s
      icmp:
        preferred_ip_protocol: "ip4"

serviceMonitor:
  enabled: true
  defaults:
    labels:
      release: prometheus-blackbox-exporter
  targets:
%{for name, params in bb_targets ~}
    - name: ${name}
      url: ${params.url}
      interval: ${params.interval}
      module: ${params.module}
%{endfor ~}
# TODO: integrate automated targets with IPAM/DCIM # FIXME: move to module.Monitoring
