terraform {
  required_providers {
    helm = {
      source = "hashicorp/helm"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
    }
    pagerduty = {
      source = "pagerduty/pagerduty"
    }
    synology = {
      source = "synology-community/synology"
    }
  }
}
