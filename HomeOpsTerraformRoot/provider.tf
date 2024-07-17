provider "routeros" {
  alias    = "hex"
  hosturl  = "http://${var.ros_hex.addr}/"
  username = var.ros_hex.user
  password = var.ros_hex.pass
  insecure = true
}
