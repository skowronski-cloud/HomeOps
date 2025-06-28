# TODO: some automation to pull latest versions of var_helm
variable "ver_helm_traefik" {
  # https://artifacthub.io/packages/helm/traefik/traefik
  default = "34.4.1"
  type    = string
}
variable "ver_helm_authelia" {
  # https://artifacthub.io/packages/helm/authelia/authelia
  default = "0.10.21"
  type    = string
}
variable "ver_helm_k8sr" {
  # https://artifacthub.io/packages/helm/deliveryhero/k8s-resources
  default = "0.8.1"
  type    = string
}
variable "ver_helm_metallb" {
  # https://artifacthub.io/packages/helm/metallb/metallb
  default = "0.14.9"
  type    = string
}
variable "ver_helm_longhorn" {
  # https://artifacthub.io/packages/helm/longhorn/longhorn
  default = "1.8.1"
  type    = string
}
variable "ver_helm_mosquitto" {
  # https://artifacthub.io/packages/helm/kfirfer/mosquitto
  default = "1.0.7"
  type    = string
}
variable "ver_helm_matter" {
  # https://artifacthub.io/packages/helm/charts-derwitt-dev/home-assistant-matter-server
  default = "3.0.0"
  type    = string
}
variable "ver_helm_ha" {
  # https://artifacthub.io/packages/helm/helm-hass/home-assistant
  default = "0.2.111"
  type    = string
}
variable "ver_app_ha" {
  # https://github.com/home-assistant/core/releases
  default = "2025.6.1"
  type    = string
}
variable "ver_helm_postgres" {
  # https://artifacthub.io/packages/helm/bitnami/postgresql
  default = "16.4.16"
  type    = string
}
variable "ver_helm_spoolman" {
  # https://artifacthub.io/packages/helm/ideaplexus/spoolman
  default = "2.4.1"
  type    = string
}
variable "ver_helm_certmanager" {
  # https://artifacthub.io/packages/helm/cert-manager/cert-manager
  default = "v1.17.1"
  type    = string
}
variable "ver_helm_certmanagercrds" {
  # https://artifacthub.io/packages/helm/wiremind/cert-manager-crds?modal=install
  default = "1.16.1"
  type    = string
}
variable "ver_helm_infrahub" {
  # https://artifacthub.io/packages/helm/infrahub/infrahub
  default = "4.3.6"
  type    = string
}
variable "ver_helm_promstack" {
  # https://artifacthub.io/packages/helm/prometheus-community/kube-prometheus-stack
  default = "75.6.0"
  type    = string
}
