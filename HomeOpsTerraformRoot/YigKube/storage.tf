
resource "helm_release" "longhorn" {
  # https://artifacthub.io/packages/helm/longhorn/longhorn
  chart      = "longhorn"
  repository = "https://charts.longhorn.io/"
  version    = var.ver_helm_longhorn

  name      = "longhorn"
  namespace = "longhorn-system"

  # TODO: default backup store - https://artifacthub.io/packages/helm/longhorn/longhorn#other-settings

  values = [templatefile("${path.module}/template/longhorn.yaml.tpl", {
    ingress_domain        = var.ingress_domain,
    workers_count         = var.workers_count,
    xasc                  = local.highlyAvailableServiceConfig
    metrics_label_release = "kube-prometheus-stack" # fixed to avoid circular dependency with prometheus stack
  })]

  depends_on = [kubernetes_namespace.ns]
}
resource "kubernetes_storage_class" "longhorn_single" {
  # this storage class uses Longhorn with a single replica for workloads that implement their own redundancy like sharding
  # https://longhorn.io/docs/1.10.0/references/storage-class-parameters
  storage_provisioner = "driver.longhorn.io"
  metadata {
    name = "longhorn-single"
  }
  parameters = {
    numberOfReplicas = "1"
    dataLocality     = "best-effort"
    replicaAutoBalance = "best-effort"
  }
}

resource "kubernetes_network_policy" "longhorn_frontend" { 
  
  metadata {
    name = "longhorn-frontend"
    namespace = "longhorn-system"
  }
  spec {
    pod_selector {
      match_expressions {
        key      = "app"
        operator = "In"
        values   = ["longhorn-ui"]
      }
    }

    ingress {
      ports {
        port     = "http"
        protocol = "TCP"
      }

      from {
        namespace_selector {
          match_labels = {
            "kubernetes.io/metadata.name" = "traefik-system"
          }
        }
      }

      from {
        namespace_selector {
          match_labels = {
            "kubernetes.io/metadata.name" = "monitoring-system"
          }
        }
      }

    }

    egress {} # single empty rule to allow all egress traffic

    policy_types = ["Ingress", "Egress"]
  }
  
}