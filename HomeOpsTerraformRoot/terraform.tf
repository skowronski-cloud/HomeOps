terraform {
  required_version = "1.12.2"
  required_providers {
    routeros = {
      # https://registry.terraform.io/providers/terraform-routeros/routeros/latest
      source  = "terraform-routeros/routeros"
      version = "1.85.3"
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
    tls = {
      source  = "hashicorp/tls"
      version = "4.1.0"
    }
  }
}
