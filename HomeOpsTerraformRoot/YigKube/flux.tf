resource "kubernetes_secret" "flux_sops_gpg" {
  metadata {
    name      = "sops-gpg"
    namespace = "flux-system"
  }
  data = {
    "identity.asc"     = base64decode(var.flux_sops_gpg.private)
    "identity.asc.pub" = base64decode(var.flux_sops_gpg.public)
  }
  depends_on = [kubernetes_namespace.ns]
}
resource "kubernetes_secret" "flux_sops_git" {
  metadata {
    name      = "ssh-credentials"
    namespace = "flux-system"
  }
  data = {
    "identity" = base64decode(var.flux_git_ssh.key)
    "known_hosts" = join("\n", [
      "github.com ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCj7ndNxQowgcQnjshcLrqPEiiphnt+VTTvDP6mHBL9j1aNUkY4Ue1gvwnGLVlOhGeYrnZaMgRK6+PKCUXaDbC7qtbW8gIkhL7aGCsOr/C56SJMy/BCZfxd1nWzAOxSDPgVsmerOBYfNqltV9/hWCqBywINIR+5dIg6JTJ72pcEpEjcYgXkE2YEFXV1JHnsKgbLWNlhScqb2UmyRkQyytRLtL+38TGxkxCflmO+5Z8CSSNY7GidjMIZ7Q4zMjA2n1nGrlTDkzwDCsw+wqFPGQA179cnfGWOWRVruj16z6XyvxvjJwbz0wQZ75XK5tKSb7FNyeIEs4TT4jk+S4dhPeAUC5y+bDYirYgM4GC7uEnztnZyaVWQ7B381AK4Qdrwt51ZqExKbQpTUNn+EjqoTwvqNj4kqx5QUCI0ThS/YkOxJCXmPUWZbhjpCg56i+2aB6CmK2JGhn57K5mj0MNdBXA4/WnwH6XoPWJzK5Nyu2zB3nAZp+S5hpQs+p1vN1/wsjk=",
      "github.com ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBEmKSENjQEezOmxkZMy7opKgwFB9nkt5YRrYMjNuG5N87uRgg6CLrbo5wAdT/y6v0mKV0U2w0WZ2YB/++Tpockg=",
      "github.com ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOMqqnkVzrm0SdG6UOoqKLsabgH5C9okWi0dh2l9GKJl"
    ])
  }
  depends_on = [kubernetes_namespace.ns]
}
resource "helm_release" "flux_operator" {
  # https://artifacthub.io/packages/helm/flux-operator/flux-operator
  repository = "oci://ghcr.io/controlplaneio-fluxcd/charts"
  chart      = "flux-operator"
  version    = var.ver_helm_fluxoperator

  name      = "flux-operator"
  namespace = "flux-system"


  depends_on = [kubernetes_namespace.ns]
}
resource "helm_release" "flux_instance_homeflux" {
  count = 1
  # https://artifacthub.io/packages/helm/flux-instance/flux-instance
  repository = "oci://ghcr.io/controlplaneio-fluxcd/charts"
  chart      = "flux-instance"
  version    = var.ver_helm_fluxinstance

  name      = "flux-instance-homeflux"
  namespace = "flux-system"

  set = [
    {
      name  = "instance.sync.kind"
      value = "GitRepository"
    },
    {
      name  = "instance.sync.url"
      value = "ssh://git@github.com/danielskowronski/HomeFlux.git"
    },
    {
      name  = "instance.sync.ref"
      value = "refs/heads/master"
    },
    {
      name  = "instance.sync.path"
      value = "./clusters/production"
    },
    {
      name  = "instance.sync.pullSecret"
      value = kubernetes_secret.flux_sops_git.metadata[0].name
    }
  ]

  depends_on = [kubernetes_secret.flux_sops_gpg, kubernetes_secret.flux_sops_git, helm_release.flux_operator, kubernetes_namespace.ns]
}

