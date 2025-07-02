variable "ff_infrahub" {
  type    = bool
  default = false
}
resource "helm_release" "infrahub_secrets" {
  count = var.ff_infrahub ? 1 : 0
  # https://artifacthub.io/packages/helm/deliveryhero/k8s-resources
  repository = "oci://ghcr.io/deliveryhero/helm-charts/"
  chart      = "k8s-resources"
  version    = var.ver_helm_k8sr

  name      = "infrahub-secrets"
  namespace = "infrahub"

  values = [
    templatefile("${path.module}/template/infrahub_secrets.yaml.tpl", {
      infrahub_neo4j_password         = base64encode(random_password.infrahub_neo4j_pass.result)
      infrahub_rabbitmq_pass          = base64encode(random_password.infrahub_rabbitmq_pass.result)
      infrahub_redis_pass             = base64encode(random_password.infrahub_redis_pass.result)
      infrahub_initial_admin_password = base64encode(random_password.infrahub_initial_admin_password.result)
      infrahub_initial_admin_token    = base64encode(random_uuid.infrahub_initial_admin_token.result)
      infrahub_security_secret_key    = base64encode(random_uuid.infrahub_security_secret_key.result)
  })]

  depends_on = [helm_release.longhorn, kubernetes_namespace.ns]
}
resource "random_uuid" "infrahub_initial_admin_token" {
}
resource "random_uuid" "infrahub_security_secret_key" {
}
resource "random_password" "infrahub_initial_admin_password" {
  length  = 128
  special = false
}
resource "random_password" "infrahub_neo4j_pass" {
  length  = 128
  special = false
}
resource "random_password" "infrahub_rabbitmq_pass" {
  length  = 128
  special = false
}
resource "random_password" "infrahub_redis_pass" {
  length  = 128
  special = false
}
resource "helm_release" "infrahub" {
  count = var.ff_infrahub ? 1 : 0
  # https://artifacthub.io/packages/helm/infrahub/infrahub
  repository = "oci://registry.opsmill.io/opsmill/chart/"
  chart      = "infrahub"
  version    = var.ver_helm_infrahub

  name      = "infrahub"
  namespace = "infrahub"

  set = [
    {
      name  = "infrahubServer.ingress.enabled"
      value = true
    },
    {
      name  = "infrahubServer.ingress.hostname"
      value = "infrahub.${var.ingress_domain}"
    },
    {
      name  = "infrahubServer.persistence.enabled"
      value = true
    },
    {
      name  = "infrahubServer.type"
      value = "LoadBalancer"
    },
    {
      name  = "neo4j.neo4j.password"
      value = random_password.infrahub_neo4j_pass.result
    },
    {
      name  = "rabbitmq.auth.password"
      value = random_password.infrahub_rabbitmq_pass.result
    },
    {
      name  = "redis.auth.enabled"
      value = true
    },
    {
      name  = "redis.auth.password"
      value = random_password.infrahub_redis_pass.result
    },
    {
      name  = "infrahubServer.infrahubServer.envFromExistingSecret"
      value = "infrahub-env"
    },
    {
      name  = "infrahubServer.infrahubServer.env.INFRAHUB_LOG_LEVEL"
      value = "DEBUG"
    }
  ]

  depends_on = [helm_release.longhorn, kubernetes_namespace.ns, helm_release.infrahub_secrets]
}
