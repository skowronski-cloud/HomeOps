resource "kubernetes_secret_v1" "bgp_password_router" {
  metadata {
    name      = "bgp-password-router"
    namespace = var.namespace
    labels = var.default_labels
  }
  type = "kubernetes.io/basic-auth"
  data = {
    username = "metallb"
    password = var.password
  }
}
resource "kubernetes_manifest" "metallb_bgp_peerings" {
  manifest = {
    apiVersion = "metallb.io/v1beta2"
    kind       = "BGPPeer"
    metadata = {
      name      = "yig-peer"
      namespace = var.namespace
      labels = var.default_labels
    }
    spec = {
      peerAddress = var.router_ip
      peerASN     = var.router_asn
      myASN       = var.metallb_asn
      passwordSecret = {
        name = kubernetes_secret_v1.bgp_password_router.metadata[0].name
      }
    }
  }
}