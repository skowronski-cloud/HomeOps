

resource "helm_release" "whereabouts" {
  # https://artifacthub.io/packages/helm/bitnami/whereabouts
  chart      = "whereabouts"
  repository = "oci://registry-1.docker.io/bitnamicharts"
  version    = var.ver_helm_whereabouts

  name      = "whereabouts"
  namespace = "multus-system"

  depends_on = [kubernetes_namespace.ns]
}

resource "helm_release" "multus" {
  # https://artifacthub.io/packages/helm/bitnami/multus-cni?modal=values
  chart      = "multus-cni"
  repository = "oci://registry-1.docker.io/bitnamicharts"
  version    = var.ver_helm_multus

  name      = "multus-cni"
  namespace = "multus-system"

  depends_on = [kubernetes_namespace.ns, helm_release.whereabouts]
}
