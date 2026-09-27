---
CustomResources:
  # https://github.com/vmware-tanzu/velero-plugin-for-aws/blob/main/backupstoragelocation.md
  - name: synology-velero-minio
    fullnameOverride: synology-velero-minio
    apiVersion: velero.io/v1
    kind: BackupStorageLocation
    spec:
      default: true
      credential:
        name: ${credential_name}
        key: cloud
      provider: aws
      objectStorage:
        bucket: ${bucket_name_prefix}-backups
      config:
        s3ForcePathStyle: "true"
        s3Url: https://${synology_velero_minio.host}:${synology_velero_minio.port}
        insecureSkipTLSVerify: "true"
        region: dummy # ref: https://github.com/velero-io/velero/issues/9963
  # https://velero.io/docs/main/api-types/schedule/
  # TODO: add labels for easdier management
  - name: daily-quick-backup # those are snapshots
    fullnameOverride: daily-quick-backup
    apiVersion: velero.io/v1
    kind: Schedule
    spec:
      schedule: 0 5 * * 1-6 # every day except sunday at 5:00 UTC = 7 CEST
      template:
        snapshotMoveData: false
        includedNamespaces:
          - '*'
        excludedNamespaces: []
        includedResources:
          - '*'
        excludedResources: []
        ttl: 360h0m0s # 15d
        labelSelector:
          matchExpressions:
            - key: skipQuickBackup
              operator: NotIn
              values:
                - "true"
  - name: weekly-full-backup # real backups
    fullnameOverride: weekly-full-backup
    apiVersion: velero.io/v1
    kind: Schedule
    spec:
      schedule: 0 8 * * 0 # every sunday at 8:00 UTC = 10 CEST
      template:
        snapshotMoveData: true
        includedNamespaces:
          - '*'
        excludedNamespaces: []
        includedResources:
          - '*'
        excludedResources: []
        ttl: 1464h0m0s # 61d
        uploaderConfig:
          parallelFilesUpload: 1 # upload also includes checksum and compression, 1 per node is safe, 4 per node means meltdown
