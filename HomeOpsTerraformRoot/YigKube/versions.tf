# TODO: some automation to pull latest versions of var_helm
variable "ver_helm_traefik" {
  # https://artifacthub.io/packages/helm/traefik/traefik
  default = "41.4.0"
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
  default = "0.8.2"
  type    = string
}
variable "ver_helm_metallb" {
  # https://artifacthub.io/packages/helm/metallb/metallb
  default = "0.16.1"
  type    = string
}
variable "ver_helm_longhorn" {
  # https://artifacthub.io/packages/helm/longhorn/longhorn
  default = "1.12.1"
  type    = string
}
variable "ver_helm_matter" {
  # https://artifacthub.io/packages/helm/charts-derwitt-dev/home-assistant-matter-server
  default = "4.2.0"
  type    = string
}
variable "ver_helm_ha" {
  # https://artifacthub.io/packages/helm/helm-hass/home-assistant
  default = "0.3.75"
  type    = string
}
variable "ver_app_ha" {
  # https://github.com/home-assistant/core/releases
  default = "2026.8.3"
  type    = string
}
variable "ver_helm_postgresha" {
  # https://artifacthub.io/packages/helm/bitnami/postgresql-ha
  default = "16.3.2"
  type    = string
}
variable "ver_helm_certmanager" {
  # https://artifacthub.io/packages/helm/cert-manager/cert-manager
  default = "1.21.1"
  type    = string
}
variable "ver_helm_certmanagercrds" {
  # https://artifacthub.io/packages/helm/wiremind/cert-manager-crds?modal=install
  default = "1.20.0"
  type    = string
}
variable "ver_helm_infrahub" {
  # https://artifacthub.io/packages/helm/infrahub/infrahub
  default = "4.5.2"
  type    = string
}
variable "ver_helm_promstack" {
  # https://artifacthub.io/packages/helm/prometheus-community/kube-prometheus-stack
  default = "88.6.1"
  type    = string
}

variable "ver_helm_blackbox" {
  # https://artifacthub.io/packages/helm/prometheus-community/prometheus-blackbox-exporter
  default = "11.17.2"
  type    = string
}
variable "ver_helm_fluxoperator" {
  # https://artifacthub.io/packages/helm/flux-operator/flux-operator
  default = "0.58.1"
  type    = string
}
variable "ver_helm_fluxinstance" {
  # https://artifacthub.io/packages/helm/flux-instance/flux-instance
  default = "0.58.1"
  type    = string
}
variable "ver_helm_velero" {
  # https://artifacthub.io/packages/helm/vmware-tanzu/velero
  default = "12.1.0"
  type    = string
}
variable "ver_docker_velero_aws" {
  # https://github.com/vmware-tanzu/velero-plugin-for-aws/releases
  default = "v1.14.2"
  type    = string
}
variable "ver_helm_snapshot_controller" {
  # https://github.com/piraeusdatastore/helm-charts/tree/main/charts/snapshot-controller
  default = "5.2.0"
  type    = string
}
variable "ver_helm_mktxp" {
  # https://artifacthub.io/packages/helm/obeone/mktxp
  default = "1.1.10"
  type    = string
}
variable "ver_docker_mktxp" {
  # https://github.com/akpw/mktxp/releases
  default = "1.2.20"
  type    = string
}
variable "ver_helm_cadvisor" {
  # https://artifacthub.io/packages/helm/bitnami/cadvisor
  default = "0.1.13"
  type    = string
}
variable "ver_helm_kepler" {
  # https://artifacthub.io/packages/helm/kepler/kepler
  default = "0.6.2"
  type    = string
}
variable "ver_helm_helmexporter" {
  # https://artifacthub.io/packages/helm/sstarcher/helm-exporter
  default = "1.3.0+109c2ba"
  type    = string
}
variable "ver_helm_multus" {
  # https://artifacthub.io/packages/helm/bitnami/multus-cni
  default = "2.2.21"
  type    = string
}
variable "ver_helm_whereabouts" {
  # https://artifacthub.io/packages/helm/bitnami/whereabouts
  default = "1.2.19"
  type    = string
}
variable "ver_helm_emqx" {
  # https://artifacthub.io/packages/helm/emqx-operator/emqx
  default = "5.8.9"
  type    = string
}
variable "ver_helm_kyverno" {
  # https://artifacthub.io/packages/helm/kyverno/kyverno
  default = "3.9.0"
  type    = string
}
variable "ver_helm_kyverno_policy_reporter" {
  # https://artifacthub.io/packages/helm/policy-reporter/policy-reporter
  default = "3.10.0"
  type    = string
}
variable "ver_helm_kyverno_policies" {
  # https://artifacthub.io/packages/helm/kyverno/kyverno-policies
  default = "3.9.0"
  type    = string
}
variable "ver_helm_homepage" { 
  # https://artifacthub.io/packages/helm/m0nsterrr-homepage/homepage
  default = "5.1.1"
  type = string
}
variable "ver_helm_vm_stack" {
  # https://artifacthub.io/packages/helm/victoriametrics/victoria-metrics-k8s-stack
  default = "0.91.2"
  type = string
}
variable "ver_helm_vm_crd" {
  # https://artifacthub.io/packages/helm/victoriametrics/victoria-metrics-operator-crds
  default = "0.14.0"
  type = string
}
variable "ver_helm_netbox" {
  # https://artifacthub.io/packages/helm/netbox/netbox
  default = "8.3.63"
  type = string
}
variable "ver_docker_netbox_custom" {
  # https://github.com/danielskowronski/custom-netbox-docker-with-plugins/releases
  default = "v4.6.9"
  type    = string
}
variable "ver_helm_podinfo" {
  # https://artifacthub.io/packages/helm/podinfo/podinfo
  default = "6.14.1"
  type = string
}