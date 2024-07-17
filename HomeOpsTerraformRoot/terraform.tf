terraform {
  required_version = "1.8.5"
  required_providers {
    routeros = {
      source  = "terraform-routeros/routeros"
      version = "1.56.0"
      # FIXME - using dev_override for https://github.com/terraform-routeros/terraform-provider-routeros/pull/508
    }
  }
}
