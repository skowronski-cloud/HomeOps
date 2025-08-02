---
CustomResources:
  - name: yig-subdomain-wildcard
    fullnameOverride: yig-subdomain-wildcard
    apiVersion: cert-manager.io/v1
    kind: Certificate
    spec:
      duration: 2160h # 90d
      renewBefore: 72h
      secretName: yig-subdomain-wildcard
      commonName: '*.${ingress_domain}'
      dnsNames:
        - '*.${ingress_domain}'
        - '${ingress_domain}'
      issuerRef:
        name: yig-ca-issuer
        kind: ClusterIssuer
  - name: traefik-default-tlsstore
    fullnameOverride: default
    apiVersion: traefik.io/v1alpha1
    kind: TLSStore
    spec:
      defaultCertificate:
        secretName: yig-subdomain-wildcard
