terraform {
  required_version = "1.15.7"
  required_providers {
    routeros = {
      # https://registry.terraform.io/providers/terraform-routeros/routeros/latest
      source  = "terraform-routeros/routeros"
      version = "1.99.1"
    }

    helm = {
      # https://registry.terraform.io/providers/hashicorp/helm/latest
      source  = "hashicorp/helm"
      version = "3.2.0"
    }
    kubernetes = {
      # https://registry.terraform.io/providers/hashicorp/kubernetes/latest
      source  = "hashicorp/kubernetes"
      version = "3.2.1"
    }
    random = {
      # https://registry.terraform.io/providers/hashicorp/random/latest
      source  = "hashicorp/random"
      version = "3.9.0"
    }
    k0s = {
      # https://registry.terraform.io/providers/danielskowronski/k0s/latest
      source  = "danielskowronski/k0s"
      version = "0.2.2-rc1"
    }
    synology = {
      # https://registry.terraform.io/providers/synology-community/synology/latest
      source  = "synology-community/synology"
      version = "0.6.11"
    }
    pagerduty = {
      # https://registry.terraform.io/providers/pagerduty/pagerduty/latest
      source  = "pagerduty/pagerduty"
      version = "3.36.0"
    }
    tls = {
      # https://registry.terraform.io/providers/hashicorp/tls/latest
      source  = "hashicorp/tls"
      version = "4.3.0"
    }
    restapi = {
      # https://registry.terraform.io/providers/Mastercard/restapi/latest
      source  = "Mastercard/restapi"
      version = "3.0.0"
    }
    ldap = {
      # https://registry.terraform.io/providers/ngharo/ldap/latest/docs
      source  = "ngharo/ldap"
      version = "2.3.1"
    }
  }
}
