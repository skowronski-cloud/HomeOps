locals {
  victoria_logs_service_name = "victoria-logs"
  victoria_logs_grafana_datasource = yamlencode({
    apiVersion = 1
    datasources = [{
      name          = "VictoriaLogs"
      uid           = "victorialogs"
      type          = "victoriametrics-logs-datasource"
      access        = "proxy"
      url           = "https://${local.victoria_logs_service_name}.logging.svc.cluster.local:${var.victoria_logs_config.api_port}"
      isDefault     = false
      editable      = false
      basicAuth     = true
      basicAuthUser = var.victoria_logs.reader_username
      jsonData = {
        tlsAuthWithCACert = true
      }
      secureJsonData = {
        basicAuthPassword = var.victoria_logs.reader_password
        tlsCACert         = base64decode(var.yig_ca_crt)
      }
    }]
  })
}

resource "kubernetes_secret" "victoria_logs_auth" {
  metadata {
    name      = "victoria-logs-auth"
    namespace = "logging"
  }

  data = {
    writer_username = var.victoria_logs.writer_username
    writer_password = var.victoria_logs.writer_password
    reader_username = var.victoria_logs.reader_username
    reader_password = var.victoria_logs.reader_password
  }

  type       = "Opaque"
  depends_on = [kubernetes_namespace.ns]
}

resource "kubernetes_secret" "grafana_victoria_logs_datasource" {
  metadata {
    name      = "grafana-victoria-logs-datasource"
    namespace = "vm"
    labels = {
      grafana_datasource = "1"
    }
  }

  data = {
    "victorialogs.yaml" = local.victoria_logs_grafana_datasource
  }

  type = "Opaque"

  depends_on = [
    helm_release.vm_stack,
    kubernetes_namespace.ns
  ]
}

resource "kubernetes_service_v1" "victoria_logs" {
  metadata {
    name      = local.victoria_logs_service_name
    namespace = "logging"
  }

  spec {
    port {
      name        = "https"
      port        = var.victoria_logs_config.api_port
      target_port = var.victoria_logs_config.api_port
      protocol    = "TCP"
    }
    type = "ClusterIP"
  }

  depends_on = [kubernetes_namespace.ns]
}

resource "kubernetes_manifest" "victoria_logs_endpoint_slice" {
  manifest = {
    apiVersion  = "discovery.k8s.io/v1"
    kind        = "EndpointSlice"
    addressType = "IPv4"
    metadata = {
      name      = "victoria-logs-1"
      namespace = "logging"
      labels = {
        "kubernetes.io/service-name" = kubernetes_service_v1.victoria_logs.metadata[0].name
      }
    }
    endpoints = [{
      addresses = [var.victoria_logs_config.host]
      conditions = {
        ready = true
      }
    }]
    ports = [{
      name     = "https"
      port     = var.victoria_logs_config.api_port
      protocol = "TCP"
    }]
  }
}

resource "helm_release" "victoria_logs_resources" {
  # https://artifacthub.io/packages/helm/deliveryhero/k8s-resources
  repository = "oci://ghcr.io/deliveryhero/helm-charts"
  chart      = "k8s-resources"
  version    = var.ver_helm_k8sr

  name        = "victoria-logs-resources"
  namespace   = "logging"
  description = "VLAgent and access resources for the NAS VictoriaLogs service"

  values = [
    templatefile("${path.module}/template/victoria_logs.yaml.tpl", {
      ingress_domain            = var.ingress_domain
      ingress_proxy_auth_header = jsonencode("Bearer ${var.victoria_logs.ingress_proxy_token}")
      service_name              = kubernetes_service_v1.victoria_logs.metadata[0].name
      api_port                  = var.victoria_logs_config.api_port
      auth_secret_name          = kubernetes_secret.victoria_logs_auth.metadata[0].name
      ca_secret_name            = kubernetes_secret.ca_crt["logging"].metadata[0].name
      vlagent_version           = var.ver_app_vlagent
      vlagent_cluster_name      = var.victoria_logs_config.vlagent_cluster_name
      vlagent_max_disk_usage    = var.victoria_logs_config.vlagent_max_disk_usage
      vlagent_cpu_request       = var.victoria_logs_config.vlagent_cpu_request
      vlagent_cpu_limit         = var.victoria_logs_config.vlagent_cpu_limit
      vlagent_memory_request    = var.victoria_logs_config.vlagent_memory_request
      vlagent_memory_limit      = var.victoria_logs_config.vlagent_memory_limit
    })
  ]

  depends_on = [
    helm_release.vm_stack,
    helm_release.traefik,
    kubernetes_manifest.victoria_logs_endpoint_slice
  ]
}
