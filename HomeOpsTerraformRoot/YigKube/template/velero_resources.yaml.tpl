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
  # https://velero.io/docs/main/api-types/schedule/
  # TODO: add labels for easdier management
  - name: daily-quick-backup
    fullnameOverride: daily-quick-backup
    apiVersion: velero.io/v1
    kind: Schedule
    spec:
      schedule: 0 4 * * 1-6 # every day except sunday at 4:00 UTC
      template:
        snapshotMoveData: false
        includedNamespaces:
          - '*'
        excludedNamespaces: []
        includedResources:
          - '*'
        excludedResources: []
        ttl: 2160h0m0s # 90d
        labelSelector:
          matchExpressions:
            - key: skipQuickBackup
              operator: NotIn
              values:
                - "true"
  - name: weekly-full-backup
    fullnameOverride: weekly-full-backup
    apiVersion: velero.io/v1
    kind: Schedule
    spec:
      schedule: 0 4 * * 0 # every sunday at 4:00 UTC 
      template:
        snapshotMoveData: true
        includedNamespaces:
          - '*'
        excludedNamespaces: []
        includedResources:
          - '*'
        excludedResources: []
        ttl: 2160h0m0s # 90d
        uploaderConfig:
          parallelFilesUpload: 2 # upload also includes checksum and compression, 1 per node is safe, 4 per node means meltdown
