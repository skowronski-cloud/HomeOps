---
# https://artifacthub.io/packages/helm/longhorn/longhorn?modal=values
persistence:
  defaultClassReplicaCount: ${workers_count}
defaultSettings:
  defaultDataPath: /data/longhorn
  storageNetwork: longhorn-system/longhorn-storage
ingress:
  enabled: true
  host: longhorn.${ingress_domain}
csi:
  # BUG: wait for https://github.com/longhorn/longhorn/issues/11617
  attacherReplicaCount: 1 # ${xasc.replicaCount}
  provisionerReplicaCount: 1 # ${xasc.replicaCount}
  resizerReplicaCount: 1 # ${xasc.replicaCount}
  snapshotterReplicaCount: 1 # ${xasc.replicaCount}

extraObjects:
  - apiVersion: k8s.cni.cncf.io/v1
    kind: NetworkAttachmentDefinition
    metadata:
      name: longhorn-storage
      namespace: longhorn-system
    spec:
      config: |
        {
          "cniVersion": "0.3.1",
          "name": "longhorn-storage",
          "type": "bridge",
          "bridge": "br-longhorn",
          "master": "eth1",
          "mtu": 9000,
          "ipam": {
            "type": "whereabouts",
            "range": "10.60.0.0/24",
            "range_start": "10.60.0.100",
            "range_end": "10.60.0.199",
            "gateway": "10.60.0.1"
          }
        }

metrics:
  serviceMonitor:
    enabled: true
    additionalLabels:
      release: ${metrics_label_release}