# TODO: some automation to pull latest versions of var_helm
variable "ver_helm_traefik" {
  # https://artifacthub.io/packages/helm/traefik/traefik
  default = "36.3.0"
  type    = string
}
variable "ver_helm_authelia" {
  # TODO: once https://github.com/hashicorp/terraform-provider-helm/issues/1609 is merged and released, 
  #       bump ver_helm_authelia to >= and inlcude skip_schema_validation in helm_release.authelia
  #       it's caused by authelia's schema conflicting with depenedencies and is acknowledged
  #       in https://github.com/authelia/chartrepo/issues/337#issuecomment-3017046873 with proposed workaround
  # https://artifacthub.io/packages/helm/authelia/authelia
  default = "0.10.25" # WARN: 0.10.26 .. 0.10.34 are incompatible!
  type    = string
}
variable "ver_helm_k8sr" {
  # https://artifacthub.io/packages/helm/deliveryhero/k8s-resources
  default = "0.8.1"
  type    = string
}
variable "ver_helm_metallb" {
  # https://artifacthub.io/packages/helm/metallb/metallb
  default = "0.15.2"
  type    = string
}
variable "ver_helm_longhorn" {
  # https://artifacthub.io/packages/helm/longhorn/longhorn
  default = "1.9.0"
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
  default = "0.3.8"
  type    = string
}
variable "ver_app_ha" {
  # https://github.com/home-assistant/core/releases
  default = "2025.8.2"
  type    = string
}
variable "ver_helm_postgresha" {
  # https://artifacthub.io/packages/helm/bitnami/postgresql-ha
  default = "16.0.22"
  type    = string
}
variable "ver_helm_spoolman" {
  # https://artifacthub.io/packages/helm/ideaplexus/spoolman
  default = "2.4.1"
  type    = string
}
variable "ver_helm_certmanager" {
  # https://artifacthub.io/packages/helm/cert-manager/cert-manager
  default = "v1.18.1"
  type    = string
}
variable "ver_helm_certmanagercrds" {
  # https://artifacthub.io/packages/helm/wiremind/cert-manager-crds?modal=install
  default = "1.18.1"
  type    = string
}
variable "ver_helm_infrahub" {
  # https://artifacthub.io/packages/helm/infrahub/infrahub
  default = "4.5.2"
  type    = string
}
variable "ver_helm_promstack" {
  # https://artifacthub.io/packages/helm/prometheus-community/kube-prometheus-stack
  default = "77.0.0" # "75.7.0"
  type    = string
}
variable "ver_helm_redis" {
  # https://artifacthub.io/packages/helm/bitnami/redis
  default = "21.2.6"
  type    = string
}

variable "ver_helm_blackbox" {
  # https://artifacthub.io/packages/helm/prometheus-community/prometheus-blackbox-exporter
  default = "11.0.0"
  type    = string
}
variable "ver_helm_fluxoperator" {
  # https://artifacthub.io/packages/helm/flux-operator/flux-operator
  default = "0.23.0"
  type    = string
}
variable "ver_helm_fluxinstance" {
  # https://artifacthub.io/packages/helm/flux-instance/flux-instance
  default = "0.23.0"
  type    = string
}
variable "ver_helm_velero" {
  # https://artifacthub.io/packages/helm/vmware-tanzu/velero
  default = "10.0.11"
  type    = string
}
variable "ver_docker_velero_aws" {
  # https://github.com/vmware-tanzu/velero-plugin-for-aws/releases
  default = "v1.12.2"
  type    = string
}
variable "ver_helm_snapshot_controller" {
  # https://github.com/piraeusdatastore/helm-charts/tree/main/charts/snapshot-controller
  default = "4.1.0"
  type    = string
}
