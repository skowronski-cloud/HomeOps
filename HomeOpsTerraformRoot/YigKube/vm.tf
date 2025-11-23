
resource "helm_release" "vm_crd" {
  # victoria-metrics-operator-crds
  chart      = "victoria-metrics-operator-crds"
  repository = "https://victoriametrics.github.io/helm-charts/"
  version    = var.ver_helm_vm_crd

  name      = "vm-crd"
  namespace = "vm"
}
resource "helm_release" "vm_stack" {
  # https://docs.victoriametrics.com/helm/victoria-metrics-k8s-stack/
  # https://artifacthub.io/packages/helm/victoriametrics/victoria-metrics-k8s-stack?modal=values
  chart      = "victoria-metrics-k8s-stack"
  repository = "https://victoriametrics.github.io/helm-charts/"
  version    = var.ver_helm_vm_stack

  name      = "vm"
  namespace = "vm"

  values = [
    templatefile("${path.module}/template/vm/stack.yaml.tpl", {
      ingress_domain     = var.ingress_domain
      storage_class_name = kubernetes_storage_class.longhorn_single.metadata[0].name
      retention          = "90d"
      storage_size       = "128Gi"
      grafana_reader_pass = random_password.vm_grafana_pass.result
    })
  ]
  depends_on = [helm_release.vm_crd]
}
