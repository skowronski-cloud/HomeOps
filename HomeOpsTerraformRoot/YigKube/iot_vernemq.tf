locals {
  mqtt_passwd_plain = {
    for name, account in var.mqtt_accounts : name => { user = account.user, pass = account.pass }
  }
  mqtt_passwd_hash = {
    for name, account in var.mqtt_accounts : name => { user = account.user, hash = bcrypt(account.pass) }
  }
  mqtt_acl_checksum = sha256(jsondecode(local.mqtt_passwd_plain))
}
#resource "kubernetes_secret" "vernemq_vmq_passwd" {
#  metadata {
#    namespace = "home-assistant"
#    name      = "vernemq-vmq-passwd"
#    labels = {
#      managed_by = "terraform" # TODO: ensure this label is present on all resources
#    }
#  }
#  data = {
#    "vmq.passwd" : templatefile("${path.module}/template/iot/vernemq_vmq.passwd.tpl", {
#      mqtt_accounts = var.mqtt_accounts
#    })
#    "vmq.passwd.hash" = jsonencode(local.mqtt_passwd_hash)
#  }
#  lifecycle {
#    ignore_changes = [data["vmq.passw"]] # avoid recreation on every change since bcrypt is randomly salted
#  }
#}
resource "kubernetes_secret" "vernemq_vmq_acl" {
  metadata {
    namespace = "home-assistant"
    name      = "vernemq-vmq-acl"
    labels = {
      managed_by = "terraform" # TODO: ensure this label is present on all resources
    }
  }
  data = {
    "vmq.acl" : templatefile("${path.module}/template/iot/vernemq_vmq.acl.tpl", {
      mqtt_accounts = var.mqtt_accounts
    })
  }
}
resource "kubernetes_secret" "vernemq_passwd" {
  metadata {
    namespace = "home-assistant"
    name      = "vernemq-passwd"
    labels = {
      managed_by = "terraform" # TODO: ensure this label is present on all resources
    }
  }
  data = yamldecode(templatefile("${path.module}/template/iot/vernemq_passwd.yaml.tpl", {
    mqtt_accounts = var.mqtt_accounts
  }))
}
resource "kubernetes_secret" "vernemq_etc" {
  metadata {
    namespace = "home-assistant"
    name      = "vernemq-etc"
    labels = {
      managed_by = "terraform" # TODO: ensure this label is present on all resources
    }
  }
  data = yamldecode(templatefile("${path.module}/template/iot/vernemq_etc.yaml.tpl", {
    mqtt_accounts = var.mqtt_accounts
    cookie = random_password.vernemq_cookie.result
  }))
}

resource "random_password" "vernemq_cookie" {
  length = 64
  special = false  
}
resource "kubernetes_secret" "vernemq_env" {
  metadata {
    namespace = "home-assistant"
    name      = "vernemq-env"
    labels = {
      managed_by = "terraform" # TODO: ensure this label is present on all resources
    }
  }
  data = {
    "DOCKER_VERNEMQ_DISTRIBUTED_COOKIE" : random_password.vernemq_cookie.result
  }
}
resource "helm_release" "vernemq" {
  # https://github.com/vernemq/docker-vernemq/tree/master/helm/vernemq#configuration
  # TODO: consider alternative that's not fauxpen-source
  repository = "https://vernemq.github.io/docker-vernemq"
  chart      = "vernemq"
  version    = var.ver_helm_vernemq

  name      = "vernemq"
  namespace = "home-assistant"

  values = [templatefile("${path.module}/template/iot/vernemq.yaml.tpl", {
    mqtt_accounts = var.mqtt_accounts
    highlyAvailableServiceConfig = local.highlyAvailableServiceConfig
    metrics_label_release        = helm_release.promstack.name
    ns  = "home-assistant"
    docker_image_tag              = var.ver_docker_vernemq
  })]


  depends_on = [helm_release.longhorn, kubernetes_namespace.ns, kubernetes_secret.vernemq_passwd, kubernetes_secret.vernemq_vmq_acl, kubernetes_secret.vernemq_etc]
}
