provider "routeros" {
  alias    = "hex"
  hosturl  = "http://${var.ros_hex.addr}/"
  username = var.ros_hex.user
  password = var.ros_hex.pass
  insecure = true
}
provider "routeros" {
  alias    = "capsman"
  hosturl  = "http://${var.ros_capsman.addr}/"
  username = var.ros_capsman.user
  password = var.ros_capsman.pass
  insecure = true
}
