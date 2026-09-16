
resource "helm_release" "vm_crd" {
  # victoria-metrics-operator-crds
  chart      = "victoria-metrics-operator-crds"
  repository = "https://victoriametrics.github.io/helm-charts/"
  version    = var.ver_helm_vm_crd

  name      = "vm-crd"
  namespace = "vm"
  description = "Victoria Metrics Operator CRDs AHID=victoriametrics/victoria-metrics-operator-crds"
}
resource "helm_release" "vm_stack" {
  # https://docs.victoriametrics.com/helm/victoria-metrics-k8s-stack/
  # https://artifacthub.io/packages/helm/victoriametrics/victoria-metrics-k8s-stack?modal=values
  chart      = "victoria-metrics-k8s-stack"
  repository = "https://victoriametrics.github.io/helm-charts/"
  version    = var.ver_helm_vm_stack

  name      = "vm"
  namespace = "vm"
  description = "Victoria Metrics Stack AHID=victoriametrics/victoria-metrics-k8s-stack"

  values = [
    templatefile("${path.module}/template/vm/stack.yaml.tpl", {
      ingress_domain     = var.ingress_domain
    }),
    templatefile("${path.module}/template/vm/vmalert.yaml.tpl", {
      ingress_domain     = var.ingress_domain
    }),
    templatefile("${path.module}/template/vm/extra.yaml.tpl", {
      grafana_reader_pass = random_password.vm_grafana_pass.result
    }),
    templatefile("${path.module}/template/vm/vmagent.yaml.tpl", {
      ingress_domain     = var.ingress_domain
    }),
    templatefile("${path.module}/template/vm/vmcluster.yaml.tpl", {
      ingress_domain     = var.ingress_domain
      storage_class_name = kubernetes_storage_class.longhorn_single.metadata[0].name
      retention          = "90d"
      storage_size       = "128Gi"
    }),
    templatefile("${path.module}/template/vm/grafana.yaml.tpl", {
      ingress_domain     = var.ingress_domain
      grafana_admin_pass = random_password.promstack_grafana_pass.result
      ingress_base_group  = var.ingress_base_group
      ingress_admin_group = var.ingress_admin_group
      common_smtp = var.common_smtp
    }),
    templatefile("${path.module}/template/vm/exporters.yaml.tpl", {
    }),
    templatefile("${path.module}/template/vm/alertmanager.yaml.tpl", {
      ingress_domain     = var.ingress_domain
    })
  ]
  depends_on = [helm_release.vm_crd]
}
