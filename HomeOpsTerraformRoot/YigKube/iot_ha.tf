resource "helm_release" "home_assistant" {
  # https://artifacthub.io/packages/helm/helm-hass/home-assistant
  repository = "http://pajikos.github.io/home-assistant-helm-chart/"
  chart      = "home-assistant"
  version    = var.ver_helm_ha

  name      = "home-assistant"
  namespace = "home-assistant"

  set = [
    {
      name  = "image.tag"
      value = var.ver_app_ha
    },
    {
      name  = "persistence.enabled"
      value = true
    },
    {
      name  = "replicaCount"
      value = 1
    }
  ]
  values = [
    templatefile("${path.module}/template/iot/home_assistant.yaml.tpl", {
      fqdn = "ha.${var.ingress_domain}"
      code_fqdn = "code-ha.${var.ingress_domain}"
    })
  ]
  depends_on = [kubernetes_namespace.ns, kubernetes_secret.home_assistant_secrets_yaml]
}
resource "kubernetes_secret" "home_assistant_secrets_yaml" {
  metadata {
    namespace = "home-assistant"
    name      = "secrets-yaml"
  }
  data = {
    "secrets-yaml" = yamlencode({
      "psql_string" : "postgresql://ha:${random_password.postgres_ha_user_pass.result}@ha-recorder-postgresql-ha-pgpool:5432/ha"
    })
  }
}
resource "kubernetes_secret" "home_assistant_ha_cfg" {
  metadata {
    namespace = "home-assistant"
    name      = "ha-cfg"
  }
  data = {
    "mqtt.yaml" = templatefile("${path.module}/template/iot/ha/mqtt.yaml.tpl", {
      "broker" : "${helm_release.iot_emqx.name}.${helm_release.iot_emqx.namespace}.svc",
      "username" : var.mqtt_accounts["ha"]["user"],
      "password" : var.mqtt_accounts["ha"]["pass"],
      "qingping_devices" : var.qingping_devices,
      "qingping_mqtt_payload_map" : var.qingping_mqtt_payload_map
      "rtl433_devices" : var.rtl433_devices
    })
    "logger.yaml" = templatefile("${path.module}/template/iot/ha/logger.yaml.tpl", {
    })
    "prometheus.yaml" = templatefile("${path.module}/template/iot/ha/prometheus.yaml.tpl", {
    })
    "automations.yaml" = templatefile("${path.module}/template/iot/ha/automations.yaml.tpl", {
    })
    "scenes.yaml" = templatefile("${path.module}/template/iot/ha/scenes.yaml.tpl", {
    })
    "scripts.yaml" = templatefile("${path.module}/template/iot/ha/scripts.yaml.tpl", {
    })
    "recorder.yaml" = templatefile("${path.module}/template/iot/ha/recorder.yaml.tpl", {
    })
  }
}
variable "qingping_mqtt_payload_map" {
  type = map(object({
    friendly_name = string
    mqtt_key      = string
    unit          = string
    device_class  = string
    state_class   = optional(string, "measurement")
    expire_after  = optional(number, 600)
  }))
  default = {
    "temperature" = {
      device_class  = "temperature"
      friendly_name = "Temperature"
      mqtt_key      = "temperature"
      unit          = "°C"
    }
    "humidity" = {
      device_class  = "humidity"
      friendly_name = "Humidity"
      mqtt_key      = "humidity"
      unit          = "%"
    }
    "battery" = {
      device_class  = "battery"
      friendly_name = "Battery"
      mqtt_key      = "battery"
      unit          = "%"
    }
    "co2" = {
      device_class  = "carbon_dioxide"
      friendly_name = "CO2"
      mqtt_key      = "co2"
      unit          = "ppm"
    }
    "pm10" = {
      device_class  = "pm10"
      friendly_name = "PM10"
      mqtt_key      = "pm10"
      unit          = "µg/m³"
    }
    "pm25" = {
      device_class  = "pm25"
      friendly_name = "PM2.5"
      mqtt_key      = "pm25"
      unit          = "µg/m³"
    }
  }
}
variable "qingping_devices" {
  type = map(object({
    mac        = string
    alias      = string
    model      = string
    binary     = optional(bool, false)
    supportsPM = optional(bool, false)
  }))
}
variable "rtl433_devices" {
  type = map(map(object({
    topic_id = string
    name     = string
    alias    = string
  })))
}
