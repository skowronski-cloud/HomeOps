resource "random_password" "promstack_grafana_pass" {
  length  = 100
  special = false
}
resource "helm_release" "promstack" {
  # https://artifacthub.io/packages/helm/prometheus-community/kube-prometheus-stack
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  version    = var.ver_helm_promstack

  name      = "kube-prometheus-stack"
  namespace = "monitoring-system"

  values = [templatefile("${path.module}/template/promstack.yaml.tpl", {
    grafana_admin_pass = random_password.promstack_grafana_pass.result
    ingress_domain     = "${var.ingress_domain}"

    ingress_base_group  = var.ingress_base_group
    ingress_admin_group = var.ingress_admin_group
  })]

  depends_on = [helm_release.longhorn, kubernetes_namespace.ns]
}
