---
CustomResources:
  - name: yig-subdomain-wildcard
    fullnameOverride: yig-subdomain-wildcard
    apiVersion: cert-manager.io/v1
    kind: Certificate
    spec:
      secretName: yig-subdomain-wildcard
      commonName: '*.${ingress_domain}'
      dnsNames:
        - '*.${ingress_domain}'
        - '${ingress_domain}'
      issuerRef:
        name: yig-ca-issuer
        kind: Issuer
  - name: traefik-default-tlsstore
    fullnameOverride: default
    apiVersion: traefik.io/v1alpha1
    kind: TLSStore
    spec:
      defaultCertificate:
        secretName: yig-subdomain-wildcard
