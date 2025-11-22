---
- LANding:
    - CA.crt:
        href: /cert/ca.crt
        icon: mdi-certificate
    - HomeFloorMap:
        href: https://hfm.${ ingress_domain } # FIXME
        icon: mdi-floor-plan
    - Fridge:
        href: https://fridge.${ ingress_domain } # FIXME
        icon: mdi-fridge
- General:
    - MikroNetView:
        href: https://mnv.${ ingress_domain } # FIXME
        icon: sh-mikrotik-light
- Monitoring:
    - Prometheus:
        href: https://prometheus.${ ingress_domain } # FIXME
        icon: sh-prometheus
    - Grafana:
        href: https://grafana.${ ingress_domain } # FIXME
        icon: sh-grafana
    - OpenSearch:
        href: https://opensearch.${ ingress_domain } # FIXME
        icon: sh-opensearch
- Alerting:
    - Gatus:
        href: ${ gatus_url }
        icon: sh-gatus
    - AlertManager:
        href: https://alertmanager.${ ingress_domain } # FIXME
        icon: sh-gatus
    - PagerDuty:
        href: https://app.pagerduty.com/
        icon: https://pd-static-assets.pagerduty.com/favicons/favicon.png
- Admin:
    - Kyverno:
        href: https://kyverno.${ ingress_domain } # FIXME
        icon: sh-kubernetes.png