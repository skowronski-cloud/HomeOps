resource "kubernetes_namespace" "ns" {
  for_each = toset([
    "metallb",
    "traefik",
    "longhorn-system",
    "home-assistant",
    "mosquitto",
    "spoolman",
    "cert-manager",
    "traefik-system",
    "infrahub",
  ])
  metadata {
    name = each.key
  }

  lifecycle {
    create_before_destroy = true
    prevent_destroy       = true
  }
}
