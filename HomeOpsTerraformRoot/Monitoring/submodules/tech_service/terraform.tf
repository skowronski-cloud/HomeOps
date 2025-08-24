terraform {
  required_providers {
    kubernetes = {
      source = "hashicorp/kubernetes"
    }
    pagerduty = {
      source = "pagerduty/pagerduty"
    }
  }
}
