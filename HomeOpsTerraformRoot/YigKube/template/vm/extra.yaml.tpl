---
extraObjects:
  - apiVersion: operator.victoriametrics.com/v1beta1
    kind: VMUser
    metadata:
      name: qingping-iot
      namespace: vm
    spec:
      username: qingping-iot
      generatePassword: true
      targetRefs:
        - crd:
            kind: VMCluster/vminsert
            name: vm-victoria-metrics-k8s-stack
            namespace: vm
          paths:
            - "/insert/0/prometheus/.*"
  - apiVersion: networking.k8s.io/v1
    kind: Ingress
    metadata:
      name: vmauth
      namespace: vm
    spec:
      ingressClassName: traefik
      rules:
        - host: vm-auth.yig.ds64.pl
          http:
            paths:
              - path: /
                pathType: Prefix
                backend:
                  service:
                    name: vmauth-vm-victoria-metrics-k8s-stack
                    port:
                      name: http
