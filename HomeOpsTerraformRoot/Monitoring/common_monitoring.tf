resource "helm_release" "common_monitoring" {
  chart = "${path.module}/charts/common_monitoring"
  name  = "common-monitoring"

  set = [
    {
      "name"  = "synology.addr"
      "value" = var.static_hosts.ds920
    },

    {
      "name"  = "nyarlathotep.addr"
      "value" = var.static_hosts.nya
    }
  ]
}
