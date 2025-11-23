locals {
  group_yig_vm_users = "yig-vm-users"
  group_yig_vm_users_dn = "cn=${local.group_yig_vm_users},${var.ldap_path}"
}
resource "ldap_entry" "group_yig_vm_users" {
  # https://registry.terraform.io/providers/l-with/ldap/latest/docs/resources/entry
  dn = local.group_yig_vm_users_dn
  data_json = jsonencode({
    description = ["TF Managed group for Yig VictoriaMetrics users)"]
    objectClass = ["top", "group"]
    name        = [local.group_yig_vm_users]
    member      = [for user in var.vm_users : ldap_entry.vm_users_objects[user.username].dn]
  })
  ignore_attributes = [
    "distinguishedName", "groupType", "instanceType", "objectCategory", "objectGUID", "objectSid", "sAMAccountName", 
    "sAMAccountType", "uSNChanged", "uSNCreated", "whenChanged", "whenCreated",
  ]
}
resource "random_password" "vm_users_password" {
  for_each = { for user in var.vm_users : user.username => user }
  length   = 64
  special  = false
}

resource "ldap_entry" "vm_users_objects" { # FIXME: replace with https://registry.terraform.io/providers/ngharo/ldap/latest/docs/resources/entry
  # https://registry.terraform.io/providers/l-with/ldap/latest/docs/resources/entry
  for_each = { for user in var.vm_users : user.username => user }
  dn       = "CN=${each.key},${var.ldap_path}"
  data_json = jsonencode({
    description  = ["TF Managed VictoriaMetrics user ${each.key}"]
    objectClass  = ["top", "person", "organizationalPerson", "user"]
    unicodePwd   = [nonsensitive(textdecodebase64(textencodebase64(random_password.vm_users_password[each.key].result, "UTF-16LE"), "UTF-16LE"))]
    name         = [each.key]
    sAMAccountName = [each.key]
  })
  ignore_attributes = [
    "distinguishedName", "groupType", "instanceType", "objectCategory", "objectGUID", "objectSid",
    "sAMAccountType", "uSNChanged", "uSNCreated", "whenChanged", "whenCreated", "accountExpires", "badPasswordTime",
    "badPwdCount", "cn", "codePage", "countryCode", "lastLogoff", "lastLogon", "logonCount", "memberOf", 
    "primaryGroupID", "pwdLastSet", "userAccountControl",
  ]
}

output "vm_users" {
  value = {
    for user in var.vm_users :
    user.username => {
      username   = user.username
      dn         = ldap_entry.vm_users_objects[user.username].dn
      attributes = ldap_entry.vm_users_objects[user.username].data_json
      id         = ldap_entry.vm_users_objects[user.username].id
      password   = random_password.vm_users_password[user.username].result
    }
  }
  sensitive = true
}
resource "helm_release" "vm_crd" {
  # victoria-metrics-operator-crds
  chart = "victoria-metrics-operator-crds"
  repository = "https://victoriametrics.github.io/helm-charts/"
  version = var.ver_helm_vm_crd

  name = "vm-crd"
  namespace = "vm"
}
#resource "helm_release" "vm_stack" {
#  # https://docs.victoriametrics.com/helm/victoria-metrics-k8s-stack/
#  # https://artifacthub.io/packages/helm/victoriametrics/victoria-metrics-k8s-stack?modal=values
#  chart = "victoria-metrics-k8s-stack"
#  repository = "https://victoriametrics.github.io/helm-charts/"
#  version = var.ver_helm_vm_stack
#
#  name = "vm"
#  namespace = "vm"
#
#  values = [ 
#    templatefile("${path.module}/template/vm/stack.yaml.tpl", {
#      ingress_domain = var.ingress_domain
#      storage_class_name = kubernetes_storage_class.longhorn_single.metadata[0].name
#      retention = "90d"
#      storage_size = "128Gi"
#    })
#   ]
#  depends_on = [helm_release.vm_crd]
#}