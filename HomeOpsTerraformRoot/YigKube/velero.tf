resource "kubernetes_secret" "velero_synology_minio" {
  metadata {
    name      = "velero-synology-minio"
    namespace = "velero"
  }
  data = {
    "cloud" = "[default]\naws_access_key_id=${var.synology_velero_minio.user}\naws_secret_access_key=${var.synology_velero_minio.pass}\n"
  }
  depends_on = [kubernetes_namespace.ns]
}
resource "helm_release" "velero" {
  # https://artifacthub.io/packages/helm/vmware-tanzu/velero
  chart      = "velero"
  name       = "velero"
  repository = "https://vmware-tanzu.github.io/helm-charts/"
  version    = var.ver_helm_velero
  namespace  = "velero"

  values = [
    templatefile("${path.module}/template/velero_values.yaml.tpl", {
      ver_plugin_aws = var.ver_docker_velero_aws
    })
  ]

  depends_on = [kubernetes_namespace.ns]
}
resource "helm_release" "external_snapshot_controller" {
  # https://github.com/piraeusdatastore/helm-charts/tree/main/charts/snapshot-controller
  chart      = "snapshot-controller"
  name       = "snapshot-controller"
  repository = "https://piraeus.io/helm-charts/"
  version    = var.ver_helm_snapshot_controller
  namespace  = "velero"

  depends_on = [kubernetes_namespace.ns]
}
resource "kubernetes_manifest" "longhorn_vsc" {
  # this is not supported by deliveryhero/k8s-resources
  manifest = {
    apiVersion = "snapshot.storage.k8s.io/v1"
    kind       = "VolumeSnapshotClass"
    metadata = {
      name = "longhorn-snapshot-class"
      labels = {
        "velero.io/backup-volumesnapshot-class" = "true"
      }
    }
    # https://longhorn.io/docs/1.9.1/snapshots-and-backups/csi-snapshot-support/csi-volume-snapshot-associated-with-longhorn-backing-image/
    driver         = "driver.longhorn.io"
    deletionPolicy = "Delete"
    parameters = {
      type        = "bi"
      export-type = "raw"
    }
  }
  depends_on = [helm_release.external_snapshot_controller]
}
resource "helm_release" "velero_resources" {
  # https://artifacthub.io/packages/helm/deliveryhero/k8s-resources
  repository = "oci://ghcr.io/deliveryhero/helm-charts"
  chart      = "k8s-resources"
  version    = var.ver_helm_k8sr

  name      = "velero-resources"
  namespace = "velero"

  # FIXME: parametrize backup schedule, consider movine some schedules to FluxCD
  values = [
    templatefile("${path.module}/template/velero_resources.yaml.tpl", {
      credential_name       = kubernetes_secret.velero_synology_minio.metadata[0].name
      bucket_name_prefix    = "yig-velero"
      synology_velero_minio = var.synology_velero_minio
    })
  ]
  depends_on = [helm_release.velero, helm_release.external_snapshot_controller, kubernetes_manifest.longhorn_vsc]
}
