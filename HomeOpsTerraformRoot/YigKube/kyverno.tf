

resource "helm_release" "kyverno" {
  # https://artifacthub.io/packages/helm/kyverno/kyverno
  chart      = "kyverno"
  repository = "https://kyverno.github.io/kyverno/"
  version    = var.ver_helm_kyverno

  name      = "kyverno"
  namespace = "kyverno-system"


  values = [
    templatefile("${path.module}/template/kyverno.yaml.tpl", {
      ingress_domain = var.ingress_domain
      metrics_label_release   = helm_release.promstack.name
    })
  ]

  depends_on = [kubernetes_namespace.ns]
}
resource "helm_release" "kyverno_policy_reporter" {
  # https://artifacthub.io/packages/helm/policy-reporter/policy-reporter
  chart      = "policy-reporter"
  repository = "https://kyverno.github.io/policy-reporter/"
  version    = var.ver_helm_kyverno_policy_reporter

  name      = "kyverno-policy-reporter"
  namespace = "kyverno-system"


  values = [
    templatefile("${path.module}/template/kyverno_policy_reporter.yaml.tpl", {
      ingress_domain = var.ingress_domain
      metrics_label_release   = helm_release.promstack.name
    })
  ]

  depends_on = [helm_release.kyverno]
}
resource "helm_release" "kyverno_policies" {
  # https://artifacthub.io/packages/helm/kyverno/kyverno-policies
  chart      = "kyverno-policies"
  repository = "https://kyverno.github.io/kyverno/"
  version    = var.ver_helm_kyverno_policies

  name      = "kyverno-policies"
  namespace = "kyverno-system"


  values = [
    templatefile("${path.module}/template/kyverno_policies.yaml.tpl", {
      ingress_domain = var.ingress_domain
      metrics_label_release   = helm_release.promstack.name
    })
  ]

  depends_on = [helm_release.kyverno]
}

resource "kubernetes_secret" "image_pull_secret" {
  for_each = var.pull_secrets
  metadata {
    name = "docker-cfg-${each.key}"
    namespace = "shared-system"
    annotations = {
      "managed-by" = "terraform"
    }
  }
  type = "kubernetes.io/dockerconfigjson"
  data = {
    ".dockerconfigjson" = jsonencode({
      auths = {
        "${each.value.server}" = {
          "username" = each.value.username
          "password" = each.value.password
          "email"    = each.value.email
          "auth"     = base64encode("${each.value.username}:${each.value.password}")
        }
      }
    })
  }
  lifecycle {
    ignore_changes = [
      metadata[0].labels
    ]
  }
}
resource "helm_release" "kyverno_roles" {
  # https://artifacthub.io/packages/helm/deliveryhero/k8s-resources
  repository = "oci://ghcr.io/deliveryhero/helm-charts"
  chart      = "k8s-resources"
  version    = var.ver_helm_k8sr

  name      = "kyverno-roles"
  namespace = "kyverno-system"

  values = [
    templatefile("${path.module}/template/kyverno_roles.yaml.tpl", {
      ingress_domain = var.ingress_domain
    })
  ]
  depends_on = [ helm_release.kyverno ]

}
resource "helm_release" "yig_kyverno" {
  chart = "${path.module}/charts/yig_kyverno"
  name = "yig-kyverno"
  namespace = "kyverno-system"
  depends_on = [ helm_release.kyverno_roles ]
}