---
# https://github.com/TwiN/gatus/tree/master?tab=readme-ov-file#configuration
storage:
  type: sqlite
  path: /data/gatus.db
  caching: true
  maximum-number-of-results: 100000
  maximum-number-of-events: 1000
web:
  port: ${ gatus_port }
ui:
  default-sort-by: "group"
alerting:
  pagerduty:
    integration-key: ${ pagerduty_yf_key }
endpoints:
  - name: "Prometheus Final"
    group: 00 Yig Services
    extra-labels:
      protocol: "https"
      url: "https://prometheus.${ ingress_domain }/-/healthy"
    url: "https://prometheus.${ ingress_domain }/-/healthy"
    client:
      insecure: true # certs are validated on Prometheus, ignore invalid certs here
    interval: 30s
    conditions:
      - "[STATUS] == 200"
#      - "[BODY] == pat(*Prometheus Server is Healthy*)'"
    alerts:
      - type: pagerduty
        failure-threshold: 20 # 10 minutes
        success-threshold: 6 # 3 minutes
        send-on-resolved: true
        description: "Prometheus ingress is down (HTTP API didn't return healthy for 10 minutes)"
%{ for name, host in gatus_final_local_icmp }
  - name: "${ name }"
    group: 10 Yig Hosts
    url: "icmp://${ host.host }"
    extra-labels:
      host: "${ host.host }"
      protocol: "icmp"
    conditions:
      - "[CONNECTED] == true"
    interval: 30s
    alerts:
      - type: pagerduty
        failure-threshold: 30 # 15 minutes
        success-threshold: 6 # 3 minutes
        send-on-resolved: true
        description: "${ name } is down (${ host.host } didn't respond to ping for 15 minutes)"
%{ endfor }
%{ for name, host in gatus_final_local_tcp }
  - name: "${ host.description }"
    group: 20 Local Services
    url: "tcp://${ host.host }:${ host.port }"
    extra-labels:
      host: "${ host.host }"
      port: "${ host.port }"
      protocol: "tcp"
    conditions:
      - "[CONNECTED] == true"
    interval: 30s
    alerts:
      - type: pagerduty
        failure-threshold: 20 # 10 minutes
        success-threshold: 6 # 3 minutes
        send-on-resolved: true
        description: "${ name } is down (${ host.host } didn't respond to tcp/${ host.port} for 10 minutes)"
%{ endfor }