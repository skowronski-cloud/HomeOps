provider "routeros" {
  alias    = "hex"
  hosturl  = "http://${var.ros_hex.addr}/"
  username = var.ros_hex.user
  password = var.ros_hex.pass
  insecure = true
}
provider "kubernetes" {
  config_path    = "~/.kube/config"
  config_context = "yig"
}
provider "helm" {
  kubernetes {
    config_path    = "~/.kube/config"
    config_context = "yig"
  }
  burst_limit = 100000
  experiments {
    manifest = false
  }
}
