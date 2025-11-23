terraform {
  required_providers {
    helm = {
      source = "hashicorp/helm"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
    }
    random = {
      source = "hashicorp/random"
    }
    tls = {
      source = "hashicorp/tls"
    }
    #k0s = {
    #  source = "danielskowronski/k0s"
    #}
    restapi = {
      source = "Mastercard/restapi"
    }
    ldap = {
      source = "ngharo/ldap"
    }
  }
}
