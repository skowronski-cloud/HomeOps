---
Secrets:
  - name: yig-ca
    fullnameOverride: yig-ca
    keys:
      tls.crt: ${ yig_ca_crt }
      tls.key: ${ yig_ca_key }
CustomResources:
  - name: yig-ca-issuer
    fullnameOverride: yig-ca-issuer
    apiVersion: cert-manager.io/v1
    kind: ClusterIssuer
    spec:
      ca:
        secretName: yig-ca
