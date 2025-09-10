---
CustomResources:
  - name: L2Advertisement
    fullnameOverride: l2
    apiVersion: metallb.io/v1beta1
    kind: L2Advertisement
    spec: {}
%{ for key, entry in metallb_ipam ~}
  - name: IPAddressPool${ title(entry.name) }
    fullnameOverride: ${ entry.name }
    apiVersion: metallb.io/v1beta1
    kind: IPAddressPool
    spec:
      addresses:
%{ for addr in entry.addresses ~}
        - ${ addr }
%{ endfor ~}
%{ if length(entry.namespaces) > 0 ~}
      namespaces:
%{ for ns in entry.namespaces ~}
        - ${ ns }
%{ endfor ~}
%{ endif ~}
%{ if length(entry.svcSelectors) > 0 ~}
      serviceSelectors:
        - matchExpressions:
%{ for sel in entry.svcSelectors ~}
          - {key: ${ sel.key }, operator: In, values: [${ join(", ", sel.values) }]}
%{ endfor ~}
      autoAssign: true
%{ endif ~}
%{ endfor ~}
