variable "replicas_high" {
  type        = number
  description = "number of replicas for highly-available services"
  default     = 3
}
variable "replicas_moderate" {
  type        = number
  description = "number of replicas for moderately-available services"
  default     = 2
}
variable "workers_count" {
  type        = number
  description = "number of worker nodes in the cluster"
  default     = 3
  # FIXME: this should be read from the cluster itself
}
locals {
  highlyAvailableServiceConfig = {
    replicaCount : var.replicas_high,
    affinityPreset : "hard",
    updateStrategy : {
      type : "RollingUpdate",
      rollingUpdate : {
        maxSurge : var.workers_count - var.replicas_high, # e.g. 2 workers and 2 replicas means maxSurge must be 0 because of hard anti-affinity
        maxUnavailable : var.replicas_high - 1
      }
    }
  }
  moderatelyAvailableServiceConfig = {
    replicaCount : var.replicas_moderate,
    affinityPreset : "hard",
    updateStrategy : {
      type : "RollingUpdate",
      rollingUpdate : {
        maxSurge : var.workers_count - var.replicas_moderate, # e.g. 2 workers and 2 replicas means maxSurge must be 0 because of hard anti-affinity
        maxUnavailable : var.replicas_moderate - 1
      }
    }
  }
}
# INFO: to be used as xasc (xxxxxAvailableServiceConfig) := highlyAvailableServiceConfig/moderatelyAvailableServiceConfig
