---
CustomResources:
  - name: IPAddressPoolWeb
    fullnameOverride: web
    apiVersion: metallb.io/v1beta1
    kind: IPAddressPool
    spec:
      addresses:
        - ${ address_ingress_main }
  - name: IPAddressPoolMatter
    fullnameOverride: matter
    apiVersion: metallb.io/v1beta1
    kind: IPAddressPool
    spec:
      addresses:
        - ${ address_ingress_matter }
      namespaces:
        - home-assistant
      serviceSelectors:
        - matchExpressions:
          - {key: app.kubernetes.io/name, operator: In, values: [home-assistant-matter-server]}
    autoAssign: true
  - name: IPAddressPoolMqtt
    fullnameOverride: mqtt
    apiVersion: metallb.io/v1beta1
    kind: IPAddressPool
    spec:
      addresses:
        - ${ address_ingress_mqtt }
      namespaces:
        - mosquitto
      serviceSelectors:
        - matchExpressions:
          - {key: app.kubernetes.io/name, operator: In, values: [mosquitto]}
    autoAssign: true
  - name: L2Advertisement
    fullnameOverride: l2
    apiVersion: metallb.io/v1beta1
    kind: L2Advertisement
    spec: {}
