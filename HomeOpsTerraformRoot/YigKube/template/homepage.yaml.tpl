---
# https://artifacthub.io/packages/helm/m0nsterrr-homepage/homepage?modal=values
# https://gethomepage.dev/configs/

ingress:
  enabled: true
  annotations:
    traefik.ingress.kubernetes.io/router.entrypoints: "websecure,web,http-bypass"
  hosts:
    - host: www.${ ingress_domain }
      paths:
        - path: /
          pathType: ImplementationSpecific
    - host: homepage.${ ingress_domain }
      paths:
        - path: /
          pathType: ImplementationSpecific
volumes:
  - name: ca-crt
    secret:
      secretName: ca-crt
  - name: homepage-config
    configMap:
      name: homepage-config
volumeMounts:
  - name: ca-crt
    mountPath: /app/public/cert/
  - mountPath: /app/config/
    name: homepage-config

config:
  allowedHosts:
    - www.${ ingress_domain }
    - homepage.${ ingress_domain }
    - www.${ ingress_domain }:8080
    - homepage.${ ingress_domain }:8080