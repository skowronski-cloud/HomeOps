resource "kubernetes_namespace" "ns" {
  for_each = toset([
    "metallb",
    "traefik",
    "longhorn-system",
    "home-assistant",
    "spoolman",
    "cert-manager",
    "traefik-system",
    "infrahub",
    "monitoring-system",
    "vm",
    "flux-system",
    "velero",
    "multus-system",
    "kyverno-system",
    "shared-system",
    "logging",
    "testing"
  ])
  metadata {
    name = each.key
  }

  lifecycle {
    create_before_destroy = true
    prevent_destroy       = true
    ignore_changes = [
      metadata[0].annotations,
      metadata[0].labels
    ]
  }

}
