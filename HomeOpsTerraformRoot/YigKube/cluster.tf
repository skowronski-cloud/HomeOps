variable "replicas" {
  type        = number
  description = "number of replicas for some services"
  default     = 2
}
variable "workers_count" {
  type        = number
  description = "number of worker nodes in the cluster"
  default     = 2
  # FIXME: this should be read from the cluster itself
}
locals {
  highlyAvailableServiceConfig = {
    replicaCount : var.replicas,
    affinityPreset : "hard",
    updateStrategy : {
      type : "RollingUpdate",
      rollingUpdate : {
        maxSurge : var.workers_count - var.replicas, # e.g. 2 workers and 2 replicas means maxSurge must be 0 because of hard anti-affinity
        maxUnavailable : var.replicas - 1
      }
    }
  }
}
