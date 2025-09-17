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
resource "kubernetes_secret" "home_assistant_mqtt_yaml" {
  metadata {
    namespace = "home-assistant"
    name      = "mqtt-yaml"
  }
  data = {
    "mqtt-yaml" = yamlencode({
      "mqtt" : {
        "broker" : "${helm_release.iot_emqx.name}.${helm_release.iot_emqx.namespace}.svc",
        "username" : var.mqtt_accounts["ha"]["user"],
        "password" : var.mqtt_accounts["ha"]["pass"],
        "discovery" : true,
        "discovery_prefix" : "homeassistant"
      }
    })
  }
}
