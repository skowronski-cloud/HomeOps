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
      value = 1 # var.replicas
    }
  ]
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
      "psql_string" : "postgresql://ha:${random_password.postgres_ha_user_pass.result}@ha-recorder-postgresql-ha-pgpool:5432/ha"
    })
  }
}
locals {
  postgres_ha_secret_length = 50     # WARN: this chart seems to be broken - see https://github.com/bitnami/charts/issues/17367
  postgres_ha_secret_special = false # WARN: this chart seems to be broken - see https://github.com/bitnami/charts/issues/17367
}
resource "random_password" "postgres_ha_user_pass" {
  # The password for the user that Home Assistant will use to connect to PostgreSQL
  length  = local.postgres_ha_secret_length
  special = local.postgres_ha_secret_special
}
resource "random_password" "postgres_ha_postgres_pass" {
  # The superuser (“postgres”) password
  length  = local.postgres_ha_secret_length
  special = local.postgres_ha_secret_special
}
resource "random_password" "postgres_ha_pgpool_admin_pass" {
  # The Pgpool-II admin console password
  length  = local.postgres_ha_secret_length
  special = local.postgres_ha_secret_special
}
resource "random_password" "postgres_ha_repmgr_pass" {
  # The RepMgr failover user's password used by Pgpool-II (in PostgreSQL, this is the "repmgr" user)
  length  = local.postgres_ha_secret_length
  special = local.postgres_ha_secret_special
}
resource "random_password" "postgres_ha_sr_check_pass" {
  # The streaming replication health checks user's password used by Pgpool-II (in PostgreSQL, this is the "sr_check_user" user)
  length  = local.postgres_ha_secret_length
  special = local.postgres_ha_secret_special
}
resource "random_password" "postgres_ha_pool_key" {
  # The AES key for decrypting the pool_passwd SCRAM entries in Pgpool-II
  length  = local.postgres_ha_secret_length
  special = local.postgres_ha_secret_special
}
resource "kubernetes_secret" "postgres_ha_credentials" {
  metadata {
    namespace = "home-assistant"
    name      = "${var.ha_postgres_instance_name}-postgresql"
  }
  data = {
    "password" : random_password.postgres_ha_user_pass.result,
    "postgres-password" : random_password.postgres_ha_postgres_pass.result,
    "admin-password" : random_password.postgres_ha_pgpool_admin_pass.result,
    "repmgr-password" : random_password.postgres_ha_repmgr_pass.result,
    "sr-check-password" : random_password.postgres_ha_sr_check_pass.result#,
    #"pool-key" : random_password.postgres_ha_pool_key.result
  }
}
resource "helm_release" "postgres_ha" {
  # https://artifacthub.io/packages/helm/bitnami/postgresql-ha
  repository = "oci://registry-1.docker.io/bitnamicharts/"
  chart      = "postgresql-ha"
  version    = var.ver_helm_postgresha

  name      = var.ha_postgres_instance_name
  namespace = "home-assistant"

  set = [
    {
      name  = "global.postgresql.database"
      value = "ha"
    },
    {
      name  = "global.postgresql.username"
      value = "ha"
    },
    {
      name  = "global.postgresql.existingSecret"
      value = "${var.ha_postgres_instance_name}-postgresql"
    },
    {
      name  = "global.pgpool.existingSecret"
      value = "${var.ha_postgres_instance_name}-postgresql"
    },
    {
      name = "pgpool.replicaCount"
      value = var.replicas
    },
    {
      name = "postgresql.replicaCount"
      value = var.replicas
    },
    {
      name = "persistence.size"
      value = "100Gi"
    }
  ]
  depends_on = [kubernetes_namespace.ns, kubernetes_secret.postgres_ha_credentials]
}
