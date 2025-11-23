terraform {
  required_version = "1.13.0"
  required_providers {
    routeros = {
      # https://registry.terraform.io/providers/terraform-routeros/routeros/latest
      source  = "terraform-routeros/routeros"
      version = "1.86.3"
    }

    helm = {
      # https://registry.terraform.io/providers/hashicorp/helm/latest
      source  = "hashicorp/helm"
      version = "3.0.2"
    }
    kubernetes = {
      # https://registry.terraform.io/providers/hashicorp/kubernetes/latest
      source  = "hashicorp/kubernetes"
      version = "2.37.1"
    }
    random = {
      # https://registry.terraform.io/providers/hashicorp/random/latest
      source  = "hashicorp/random"
      version = "3.7.2"
    }
    k0s = {
      # https://registry.terraform.io/providers/danielskowronski/k0s/latest
      source  = "danielskowronski/k0s"
      version = "0.2.2-rc1"
    }
    synology = {
      # https://registry.terraform.io/providers/synology-community/synology/latest
      source  = "synology-community/synology"
      version = "0.5.1"
    }
    pagerduty = {
      # https://registry.terraform.io/providers/pagerduty/pagerduty/latest
      source  = "pagerduty/pagerduty"
      version = "3.28.1"
    }
    tls = {
      # https://registry.terraform.io/providers/hashicorp/tls/latest
      source  = "hashicorp/tls"
      version = "4.1.0"
    }
    restapi = {
      # https://registry.terraform.io/providers/Mastercard/restapi/latest
      source  = "Mastercard/restapi"
      version = "2.0.1"
    }
    ldap = {
      # https://registry.terraform.io/providers/ngharo/ldap/latest/docs
      source  = "ngharo/ldap"
      version = "2.2.0"
    }
  }
}
