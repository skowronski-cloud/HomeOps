resource "helm_release" "home_assistant" {
  # https://artifacthub.io/packages/helm/helm-hass/home-assistant
  repository = "http://pajikos.github.io/home-assistant-helm-chart/"
  chart      = "home-assistant"
  version    = var.ver_helm_ha

  name      = "home-assistant"
  namespace = "home-assistant"

  set {
    name  = "image.tag"
    value = var.ver_app_ha
  }
  set {
    name  = "persistence.enabled"
    value = true
  }
  values = [
    templatefile("${path.module}/template/home_assistant.yaml.tpl", {
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
      "psql_string" : "postgresql://ha:${random_password.postgres_ha_pass.result}@ha-recorder-postgresql.home-assistant.svc.cluster.local:5432/ha"
    })
  }
}
resource "random_password" "postgres_ha_pass" {
  length  = 100
  special = false
}
resource "random_password" "postgres_ha_adminpass" {
  length  = 100
  special = true
}
resource "kubernetes_secret" "postgres_ha_credentials" {
  metadata {
    namespace = "home-assistant"
    name      = "${var.ha_postgres_instance_name}-postgresql"
  }
  data = {
    "password" : random_password.postgres_ha_pass.result,
    "postgres-password" : random_password.postgres_ha_pass.result,
  }
}
resource "helm_release" "postgres_ha" {
  # https://artifacthub.io/packages/helm/bitnami/postgresql
  repository = "oci://registry-1.docker.io/bitnamicharts/"
  chart      = "postgresql"
  version    = var.ver_helm_postgres

  name      = var.ha_postgres_instance_name
  namespace = "home-assistant"

  set {
    name  = "postgresql.auth.database"
    value = "ha"
  }
  set {
    name  = "postgresql.auth.username"
    value = "ha"
  }
  set {
    name  = "postgresql.auth.password"
    value = random_password.postgres_ha_pass.result
  }
  set {
    name  = "postgresql.auth.postgresPassword"
    value = random_password.postgres_ha_adminpass.result
  }
  depends_on = [kubernetes_namespace.ns, kubernetes_secret.postgres_ha_credentials]
}
