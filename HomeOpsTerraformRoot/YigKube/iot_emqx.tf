
resource "random_password" "iot_emqx_token_terraform" {
  length  = 64
  special = false
}
resource "kubernetes_secret" "iot_emqx_cfg" {
  metadata {
    namespace = "home-assistant"
    name      = "emqx-cfg"
  }
  data = {
    "acl.conf" = templatefile("${path.module}/template/iot/emqx_acl.conf.tpl", {
      mqtt_accounts = var.mqtt_accounts
    })
    "default_api_key.conf" = "terraform:${random_password.iot_emqx_token_terraform.result}:administrator"
  }
}
resource "random_password" "iot_emqx_password_admin" {
  length  = 64
  special = false
}
resource "helm_release" "iot_emqx" {
  # https://artifacthub.io/packages/helm/emqx-operator/emqx
  repository = "https://repos.emqx.io/charts/"
  chart      = "emqx"
  version    = var.ver_helm_emqx

  name      = "emqx"
  namespace = "home-assistant"

  values = [templatefile("${path.module}/template/iot/emqx.yaml.tpl", {
    mqtt_accounts           = var.mqtt_accounts
    xasc                    = local.highlyAvailableServiceConfig,
    ingress_domain          = var.ingress_domain,
    emqx_dashboard_password = random_password.iot_emqx_password_admin.result
    metrics_label_release   = helm_release.promstack.name
  })]


  depends_on = [helm_release.longhorn, kubernetes_namespace.ns, kubernetes_secret.iot_emqx_cfg]

  wait_for_jobs = true
  wait          = true
}

data "kubernetes_secret" "iot_emqx_token" {
  metadata {
    namespace = "home-assistant"
    name      = "emqx-basic-auth"
  }
}
provider "restapi" {
  alias = "iot_emqx"
  uri   = "https://emqx-dashboard.${var.ingress_domain}/api/v5/"

  headers = {
    Authorization = "Basic ${base64encode("terraform:${random_password.iot_emqx_token_terraform.result}")}"
    Content-Type  = "application/json"
    Accept        = "application/json"
  }
}

data "http" "iot_emqx_ready" {
  url    = "https://emqx-dashboard.${var.ingress_domain}/api/v5/authentication"
  method = "GET"

  request_headers = {
    Authorization = "Basic ${base64encode("terraform:${random_password.iot_emqx_token_terraform.result}")}"
    Content-Type  = "application/json"
    Accept        = "application/json"
  }

  depends_on = [helm_release.iot_emqx]

  retry {
    attempts = 10
  }

  lifecycle {
    postcondition {
      condition     = self.status_code == 200
      error_message = "EMQX authentication endpoint not ready (got ${self.status_code})."
    }
  }
}

resource "restapi_object" "user" {
  for_each     = var.mqtt_accounts
  path         = "/authentication/password_based%3Abuilt_in_database/users"
  provider     = restapi.iot_emqx
  read_path    = "/authentication/password_based%3Abuilt_in_database/users/${each.value.user}"
  update_path  = "/authentication/password_based%3Abuilt_in_database/users/${each.value.user}"
  destroy_path = "/authentication/password_based%3Abuilt_in_database/users/${each.value.user}"
  id_attribute = "user_id"

  data = jsonencode({
    user_id      = each.value.user
    password     = each.value.pass
    is_superuser = false
  })
  read_data = jsonencode({
    is_superuser = false
  })
  update_data = jsonencode({
    password     = each.value.pass
    is_superuser = false
  })
  destroy_data = jsonencode({
    password     = each.value.pass
    is_superuser = false
  })
  ignore_changes_to = [
    "password",
  ]

  depends_on = [data.http.iot_emqx_ready]
}

resource "restapi_object" "acl" {
  for_each      = var.mqtt_accounts
  path          = "/authorization/sources/built_in_database/rules/users/${each.value.user}"
  provider      = restapi.iot_emqx
  read_path     = "/authorization/sources/built_in_database/rules/users/${each.value.user}"
  update_path   = "/authorization/sources/built_in_database/rules/users/${each.value.user}"
  destroy_path  = "/authorization/sources/built_in_database/rules/users/${each.value.user}"
  id_attribute  = "username"
  create_method = "PUT"

  data = jsonencode({
    username = each.value.user
    rules = concat([
      {
        "action"     = "all"
        "permission" = "allow"
        "topic"      = "${each.value.user}/#"
        "qos"        = [0, 1, 2]
        "retain"     = "all"
      },
      {
        "action"     = "all"
        "permission" = "allow"
        "topic"      = "homeassistant/+/${each.key}/+/config"
        "qos"        = [0, 1, 2]
        "retain"     = "all"
      }
    ], each.value.emqx_acl)
  })

  depends_on = [data.http.iot_emqx_ready]
}
