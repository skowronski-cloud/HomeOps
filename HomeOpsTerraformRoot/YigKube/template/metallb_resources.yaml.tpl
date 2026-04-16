---
CustomResources:
%{ for key, entry in metallb_ipam ~}
%{ if length(entry.addresses) > 0 ~}
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
      serviceAllocation:
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
%{ endif ~}
%{ endfor ~}

  - name: L2Advertisement
    fullnameOverride: l2
    apiVersion: metallb.io/v1beta1
    kind: L2Advertisement
    spec:
      ipAddressPools:
%{ for key, entry in metallb_ipam ~}
%{ if length(entry.addresses) > 0 ~}
        - ${ entry.name }
%{ endif ~}
%{ endfor ~}

%{ for key, entry in metallb_ipam ~}
%{ if length(entry.bgp_addresses) > 0 ~}
  - name: IPAddressPool${ title(entry.name) }BGP
    fullnameOverride: ${ entry.name }-bgp
    apiVersion: metallb.io/v1beta1
    kind: IPAddressPool
    spec:
      addresses:
%{ for addr in entry.bgp_addresses ~}
        - ${ addr }
%{ endfor ~}
%{ if length(entry.namespaces) > 0 ~}
      namespaces:
%{ for ns in entry.namespaces ~}
        - ${ ns }
%{ endfor ~}
%{ endif ~}
      serviceAllocation:
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
%{ endif ~}
%{ endfor ~}

  - name: BGPAdvertisement
    fullnameOverride: l3
    apiVersion: metallb.io/v1beta1
    kind: BGPAdvertisement
    spec:
      ipAddressPools:
%{ for key, entry in metallb_ipam ~}
%{ if length(entry.bgp_addresses) > 0 ~}
        - ${ entry.name }-bgp
%{ endif ~}
%{ endfor ~}