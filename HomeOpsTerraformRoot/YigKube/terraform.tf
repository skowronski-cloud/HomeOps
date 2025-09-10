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
  }
}

# TODO: create sinlg local variable for all helm charts that would include highlyAvailableServiceConfig, metrics_label_release, etc.