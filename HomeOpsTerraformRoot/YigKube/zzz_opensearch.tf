## resource "helm_release" "opensearch_reloader" {
##   # https://artifacthub.io/packages/helm/stakater/reloader
##   chart      = "reloader"
##   repository = "https://stakater.github.io/stakater-charts"
##   version    = var.var_helm_opensearch_reloader
## 
##   name      = "opensearch-reloader"
##   namespace = "logging"
## 
##   values = [
##     templatefile("${path.module}/template/opensearch/reloader_values.yaml.tpl", {
## 
##     })
##   ]
## 
##   depends_on = [kubernetes_namespace.ns]
## }
## resource "random_password" "opensearch_admin_pass" {
##   length = 64
##   special = false
## }
## resource "random_password" "opensearch_dashboards_pass" {
##   length = 64
##   special = false
## }
## locals {
##   opensearch_dashboards_user = "dashboards_svc"
## }
## resource "helm_release" "opensearch_dashboards" {
##   # https://artifacthub.io/packages/helm/opensearch-project-helm-charts/opensearch-dashboards
##   chart      = "opensearch-dashboards"
##   repository = "https://opensearch-project.github.io/helm-charts/"
##   version    = var.ver_helm_opensearch
## 
##   name      = "opensearch-dashboards"
##   namespace = "logging"
## 
## 
##   values = [
##     templatefile("${path.module}/template/opensearch/dashboards_values.yaml.tpl", {
##       ingress_domain = var.ingress_domain
##       metrics_label_release   = helm_release.promstack.name
##       storage_class_name = kubernetes_storage_class.longhorn_single.metadata[0].name
##       opensearch_volume_size = "32Gi"
##       ns = "logging"
##       cluster = "opensearch-cluster"
##       yig_ingress_admin_group = var.ingress_admin_group
##       opensearch_dashboards_user = local.opensearch_dashboards_user
##       opensearch_dashboards_password = random_password.opensearch_dashboards_pass.result
##     })
##   ]
## 
##   depends_on = [kubernetes_namespace.ns, helm_release.opensearch]
## }
## resource "helm_release" "opensearch" {
##   # https://artifacthub.io/packages/helm/opensearch-project-helm-charts/opensearch
##   chart      = "opensearch"
##   repository = "https://opensearch-project.github.io/helm-charts/"
##   version    = var.ver_helm_opensearch
## 
##   name      = "opensearch"
##   namespace = "logging"
## 
## 
##   values = [
##     templatefile("${path.module}/template/opensearch/values.yaml.tpl", {
##       ingress_domain = var.ingress_domain
##       metrics_label_release   = helm_release.promstack.name
##       storage_class_name = kubernetes_storage_class.longhorn_single.metadata[0].name
##       opensearch_volume_size = "32Gi"
##       ns = "logging"
##       cluster = "opensearch-cluster"
##       yig_ingress_admin_group = var.ingress_admin_group
##       opensearch_dashboards_user = local.opensearch_dashboards_user
##       opensearch_dashboards_password_bcrypt = random_password.opensearch_dashboards_pass.bcrypt_hash
##       opensearch_admin_password_bcrypt = random_password.opensearch_admin_pass.bcrypt_hash
##     })
##   ]
## 
##   depends_on = [kubernetes_namespace.ns]
## }
## #resource "helm_release" "fluentbit" {
## #  # https://artifacthub.io/packages/helm/fluent/fluent-bit
## #  chart      = "fluent-bit"
## #  repository = "https://fluent.github.io/helm-charts"
## #  version    = var.ver_helm_fluentbit
## #
## #  name      = "fluent-bit"
## #  namespace = "logging"
## #
## #
## #  values = [
## #    templatefile("${path.module}/template/fluentbit_values.yaml.tpl", {
## #      ingress_domain = var.ingress_domain
## #      metrics_label_release   = helm_release.promstack.name
## #      storage_class_name = kubernetes_storage_class.longhorn_single.metadata[0].name
## #      opensearch_volume_size = "32Gi"
## #    })
## #  ]
## #
## #  depends_on = [kubernetes_namespace.ns]
## #}