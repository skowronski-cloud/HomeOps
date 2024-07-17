
variable "reselect_interval" {
  type    = string
  default = "1m..2m"
}
variable "skip_dfs_channels" {
  type    = string
  default = "disabled"
}
variable "country" {
  type    = string
  default = "Poland"
}
variable "wireless_config" {
  // FIXME - schema
  // TODO - alias for wpa/wpa2 and wpa2/wpa3
  // TODO - make band and with global as ax works fine on ROS
  default = {
    "home" = {
      "auth" = {
        "ssid"  = "HomeNet"
        "pass"  = "strongpass1"
        "types" = ["wpa2-psk", "wpa3-psk"]
      }
      "chains"    = [0, 1]
      "isolation" = false
      "2ghz" = {
        "band"  = "2ghz-ax"
        "width" = "20/40mhz"
      }
      "5ghz" = {
        "band"  = "5ghz-ax"
        "width" = "20/40/80mhz"
      }
    }
    "guest" = {
      "auth" = {
        "ssid"  = "GuestNet"
        "pass"  = "strongpass2"
        "types" = ["wpa-psk", "wpa2-psk"]
      }
      "chains"    = [0]
      "isolation" = true
      "2ghz" = {
        "band"  = "2ghz-ax"
        "width" = "20/40mhz"
      }
      "5ghz" = {
        "band"  = "5ghz-ax"
        "width" = "20/40/80mhz"
      }
    }
    "iot" = {
      "auth" = {
        "ssid"  = "IoTNet"
        "pass"  = "strongpass3"
        "types" = ["wpa-psk", "wpa2-psk"]
      }
      "chains"    = [1]
      "isolation" = true
      "2ghz" = {
        "band"  = "2ghz-ax"
        "width" = "20/40mhz"
      }
      "5ghz" = {
        "band"  = "5ghz-ax"
        "width" = "20/40/80mhz"
      }
    }
  }
}

