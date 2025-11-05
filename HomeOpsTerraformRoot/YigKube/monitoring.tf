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

    common_smtp = var.common_smtp
  })]

  depends_on = [helm_release.longhorn, kubernetes_namespace.ns]
}
resource "helm_release" "blackbox" {
  # https://artifacthub.io/packages/helm/prometheus-community/prometheus-blackbox-exporter
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "prometheus-blackbox-exporter"
  version    = var.ver_helm_blackbox

  name      = "prometheus-blackbox-exporter"
  namespace = "monitoring-system"

  values = [templatefile("${path.module}/template/blackbox.yaml.tpl", {
    grafana_admin_pass = random_password.promstack_grafana_pass.result
    ingress_domain     = "${var.ingress_domain}"
    bb_targets         = var.bb_targets
  })]

  depends_on = [helm_release.longhorn, kubernetes_namespace.ns]
}
resource "helm_release" "mktxp" {
  # https://artifacthub.io/packages/helm/obeone/mktxp?modal=values
  repository = "https://charts.obeone.cloud"
  chart      = "mktxp"
  version    = var.ver_helm_mktxp

  name      = "mktxp"
  namespace = "monitoring-system"

  values = [templatefile("${path.module}/template/mktxp.yaml.tpl", {
    ingress_domain                = var.ingress_domain
    image_version                 = var.ver_docker_mktxp
    mikrotik_monitoring_router_ip = var.mikrotik_monitoring_router_ip
    mikrotik_monitoring_account   = var.mikrotik_monitoring_account
    metrics_label_release         = helm_release.promstack.name
  })]

  depends_on = [helm_release.longhorn, kubernetes_namespace.ns]
}
resource "helm_release" "cadvisor" {
  # https://artifacthub.io/packages/helm/bitnami/cadvisor
  repository = "oci://registry-1.docker.io/bitnamicharts/"
  chart      = "cadvisor"
  version    = var.ver_helm_cadvisor

  name      = "cadvisor"
  namespace = "monitoring-system"

  set = [
    {
      name  = "metrics.enabled"
      value = true
    },
    {
      name  = "metrics.serviceMonitor.enabled"
      value = true
    },
    {
      name  = "metrics.serviceMonitor.labels.release"
      value = helm_release.promstack.name
    },
    {
      name = "image.repository"
      value = "bitnami/cadvisor"  # BUG: FUCK BROADCOM # BUG: this one is not on legacy...
    },
    {
      name = "global.security.allowInsecureImages"
      value = "true"  # BUG: FUCK BROADCOM
    }
  ]


  depends_on = [helm_release.longhorn, kubernetes_namespace.ns]
}
resource "helm_release" "kepler" {
  # https://artifacthub.io/packages/helm/kepler/kepler
  repository = "https://sustainable-computing-io.github.io/kepler-helm-chart"
  chart      = "kepler"
  version    = var.ver_helm_kepler

  name      = "kepler"
  namespace = "monitoring-system"

  set = [
    {
      name  = "serviceMonitor.enabled"
      value = true
    },
    {
      name  = "serviceMonitor.labels.release"
      value = helm_release.promstack.name
    }
  ]


  depends_on = [helm_release.longhorn, kubernetes_namespace.ns]
}
resource "helm_release" "helm_exporter" {
  # https://artifacthub.io/packages/helm/sstarcher/helm-exporter
  repository = "https://shanestarcher.com/helm-charts/"
  chart      = "helm-exporter"
  version    = var.ver_helm_helmexporter

  name      = "helm-exporter"
  namespace = "monitoring-system"

  values = [templatefile("${path.module}/template/helmexporter.yaml.tpl", {
    metrics_label_release = helm_release.promstack.name
    ingress_domain        = var.ingress_domain
    common_smtp           = var.common_smtp
  })]


  depends_on = [helm_release.longhorn, kubernetes_namespace.ns]
}
