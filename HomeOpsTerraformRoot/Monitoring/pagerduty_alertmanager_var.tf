variable "monitoring_services" {
  type = map(object({
    pd_name        = string
    pd_description = optional(string, "")
    prom_svc_label = optional(string, "")
    matchers = optional(list(object({
      name  = string
      value = string
      type  = optional(string, "=")
    })), [])
    group_by = optional(list(string), [])
  }))
  default = {
    "flux" = {
      pd_name        = "[k8s] FluxCD and GitOps"
      pd_description = ""
      prom_svc_label = "flux"
      # TODO: monitor stuck syncs and other FluxCD issues
      # TODO: check FluxCD exporters and define alerts
    },
    "fridge" = {
      pd_name        = "[k8s] Fridge dashboard"
      pd_description = ""
      prom_svc_label = "fridge"
      # TODO: monitor service availability
      # TODO: monitor failing cron jobs and their durations
    },
    "apps" = {
      pd_name        = "[k8s] Apps"
      pd_description = "User defined apps: MikroNetView, HomeFloorMap etc."
      prom_svc_label = "apps"
      # TODO: monitor service availability of ingresses matching some dedicated label
    },
    "smarthome" = {
      pd_name        = "[k8s] SmartHome"
      pd_description = "Home Assistant, MQTT, Matter"
      prom_svc_label = "smarthome"
      # TODO: monitor service availability of HA-Recorder, MQTT, Matter etc.
      # TODO: monitor resource usage of those components including disk usage
      # TODO: monitor condition of recorder DB
      # TODO: monitor availability of important integrations (e.g. MQTT, Tuya, HomeKit, Matter)
    },
    "kube_system_vendor" = {
      pd_name        = "[k8s] kube-system (vendor)"
      pd_description = "Core Kubernetes system components - shipped with Prometheus Operator"
      matchers = [
        {
          name  = "alertgroup"
          type  = "=~"
          value = "^(kube-state-metrics|kubernetes-system|kube-apiserver-slos|kubernetes-system-apiserver|kubernetes-system-controller-manager|kubernetes-system-kube-proxy|kubernetes-system-kubelet)$"
        }
      ]
    },
    "kube_system" = {
      pd_name        = "[k8s] kube-system"
      pd_description = "Core Kubernetes system components - custom alerts"
      prom_svc_label = "kube_system"
      # TODO: monitor kubernetes control plane components (check some k0s suggestions)
      # TODO: monitor NLLB
      # TODO: monitor CoreDNS
      # TODO: monitor k0s' built-in etcd metrics
    },
    "kube_user_vendor" = {
      pd_name        = "[k8s] Kubernetes workloads and resources (vendor)"
      pd_description = "General workloads and resources monitoring - shipped with Prometheus Operator"
      matchers = [
        {
          name  = "alertgroup"
          type  = "=~"
          value = "^(kubernetes-apps|kubernetes-resources|kubernetes-storage)$"
        }
      ]
    },
    "kube_storage" = {
      pd_name        = "[k8s] Storage"
      pd_description = "Longhorn, Velero"
      prom_svc_label = "kube_storage"
      # TODO: get standard Longhorn alerts working (including space on drives)
      # TODO: get standard Velero alerts working
      # TODO: monitor some important PVCs
      # TODO: monitor backups
      # TODO: check Longhorn exporters and define alerts
      # TODO: check Velero exporters and define alerts
    },
    "ingress" = {
      pd_name        = "[k8s] Ingress and Auth"
      pd_description = "Traefik, cert-manager, MetalLB, Authelia"
      prom_svc_label = "ingress"
      # TODO: monitor neraly expired certs
      # TODO: monitor Authelaia availability
      # TODO: monitor Authelia's Redis
      # TODO: monitor Traefik status
      # TODO: monitor MetalLB status
      # TODO: check Traefik exporters and define alerts
      # TODO: check Authelia exporters and define alerts
      # TODO: check MetalLB exporters and define alerts
    },
    "monitoring_vendor" = {
      pd_name        = "[k8s] Monitoring System (vendor)"
      pd_description = "Prometheus, Alertmanager, Grafana"
      matchers = [
        {
          name  = "alertgroup"
          type  = "=~"
          value = "^(alertmanager.rules|config-reloaders|prometheus|prometheus-operator)$"
        }
      ]
    },
    "monitoring" = {
      pd_name        = "[k8s] Monitoring System"
      pd_description = "Prometheus, Alertmanager, Grafana"
      prom_svc_label = "monitoring"
      # TODO: monitor Prometheus, Alertmanager and Grafana target availability
    },
    "host" = {
      pd_name        = "[metal] Physical Host Machines"
      pd_description = "Physical host machines"
      matchers = [
        {
          name  = "node"
          type  = "=~"
          value = "dagon|yig.*"
        }
      ]
    },
    "thermal" = {
      pd_name        = "[metal] Thermal Monitoring"
      pd_description = "YNCE and on-board thermal sensors"
      prom_svc_label = "thermal"
    },
    "net_local" = {
      pd_name        = "[net] Local Network monitoring"
      pd_description = "Hosts and devices on the local network"
      prom_svc_label = "net_local"
      # TODO: match blackbox metrics for local devices
      # TODO: check exporters for MikroTik routers and APs
    },
    "net_internet" = {
      pd_name        = "[net] Internet connectivity"
      pd_description = ""
      prom_svc_label = "net_internet"
      # TODO: match blackbox metrics for endpoints on the internet
      # TODO: check speedtest exporters (safe ones) and define alerts
    },
    "ext_workstations" = {
      pd_name        = "[ext] Workstations"
      pd_description = "macOS and Windows workstations"
      prom_svc_label = "ext_workstations"
      # TODO: define specific alerts for workstations from node exporter data
    },
    "ext_nya" = {
      pd_name        = "[ext] Nyarlathotep"
      prom_svc_label = "ext_nya"
      # TODO: define alerts for Nya node exporter data
    },
    "ext_synology" = {
      pd_name        = "[ext] Synology NAS"
      pd_description = "DS920"
      prom_svc_label = "ext_synology"
      # TODO: build upon standard node exporter alerts but specifically for NAS
      # TODO: monitor services exposed by Synology to Yig (LDAP, SMB etc.)
      # TODO: monitor UPS connected to Synology
    },
    "operator" = {
      pd_name        = "[general] Manual operator alerts"
      pd_description = "System updates, backups, other manual tasks"
      prom_svc_label = "operator"
      # TODO: check some exporters for updates required, espcially for HA
      # TODO: ???
    }
  }
}
