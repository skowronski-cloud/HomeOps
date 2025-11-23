locals {
  // userAccountControl tags
  // Enforcment based on the sum of tags
  // https://learn.microsoft.com/en-us/troubleshoot/windows-server/active-directory/useraccountcontrol-manipulate-account-properties
  ldap_tags = {
    ACCOUNTDISABLE                 = 2
    HOMEDIR_REQUIRED               = 8
    LOCKOUT                        = 16
    PASSWD_NOTREQD                 = 32
    PASSWD_CANT_CHANGE             = 64
    ENCRYPTED_TEXT_PWD_ALLOWED     = 128
    TEMP_DUPLICATE_ACCOUNT         = 256
    NORMAL_ACCOUNT                 = 512
    INTERDOMAIN_TRUST_ACCOUNT      = 2048
    WORKSTATION_TRUST_ACCOUNT      = 4096
    SERVER_TRUST_ACCOUNT           = 8192
    DONT_EXPIRE_PASSWORD           = 65536
    MNS_LOGON_ACCOUNT              = 131072
    SMARTCARD_REQUIRED             = 262144
    TRUSTED_FOR_DELEGATION         = 524288
    NOT_DELEGATED                  = 1048576
    USE_DES_KEY_ONLY               = 2097152
    DONT_REQ_PREAUTH               = 4194304
    PASSWORD_EXPIRED               = 8388608
    TRUSTED_TO_AUTH_FOR_DELEGATION = 16777216
  }
  group_yig_vm_users      = "yig-vm-users"
  group_yig_ingress_users = "yig-ingress-users"


  group_yig_vm_users_dn      = "CN=${local.group_yig_vm_users},${var.ldap_path}"
  group_yig_ingress_users_dn = "CN=${local.group_yig_ingress_users},${var.ldap_path}"
}
resource "ldap_entry" "group_yig_ingress_users" {
  # https://registry.terraform.io/providers/l-with/ldap/latest/docs/resources/entry
  dn = local.group_yig_ingress_users_dn
  attributes = {
    description = ["TF Managed group for Yig Ingress users - ldap_entry.group_yig_ingress_users"]
    objectClass = ["top", "group"]
    member      = concat([for user in var.vm_users : ldap_entry.vm_users_objects[user.username].dn], ["CN=daniel,${var.ldap_path}"])
  }
}
resource "ldap_entry" "group_yig_vm_users" {
  dn = local.group_yig_vm_users_dn
  attributes = {
    description = ["TF Managed group for Yig VictoriaMetrics users - ldap_entry.group_yig_vm_users"]
    objectClass = ["top", "group"]
    member      = [for user in var.vm_users : ldap_entry.vm_users_objects[user.username].dn]
  }
}
resource "random_password" "vm_users_password" {
  for_each = { for user in var.vm_users : user.username => user }
  length   = 64
  special  = false
}
resource "random_integer" "vm_users_password" {
  for_each = { for user in var.vm_users : user.username => user }
  min      = 1
  max      = 9999999
  keepers = {
    "pass" = random_password.vm_users_password[each.key].result
  }
}


resource "ldap_entry" "vm_users_objects" {
  for_each = { for user in var.vm_users : user.username => user }
  dn       = "CN=${each.key},${var.ldap_path}"
  attributes = {
    description        = ["TF Managed VictoriaMetrics user - ldap_entry.vm_users_objects[\"${each.key}\"]"]
    objectClass        = ["top", "person", "organizationalPerson", "user"]
    sAMAccountName     = [each.key]
    userAccountControl = [tostring(local.ldap_tags.NORMAL_ACCOUNT + local.ldap_tags.DONT_EXPIRE_PASSWORD)]

  }

  attributes_wo = {
    unicodePwd = [random_password.vm_users_password[each.key].result]
  }

  attributes_wo_version = random_integer.vm_users_password[each.key].result
}

output "vm_users" {
  value = {
    for user in var.vm_users :
    user.username => {
      username   = user.username
      dn         = ldap_entry.vm_users_objects[user.username].dn
      attributes = ldap_entry.vm_users_objects[user.username].attributes
      id         = ldap_entry.vm_users_objects[user.username].id
      password   = random_password.vm_users_password[user.username].result
    }
  }
  sensitive = true
}
