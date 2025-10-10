---
ClusterRoles:
  - name: kyverno-generate-secrets
    fullnameOverride: kyverno-generate-secrets
    rules:
      - apiGroups: [""]
        resources: ["serviceaccounts"]
        verbs: ["get", "list", "watch", "update", "patch"]
      - apiGroups: [""]
        resources: ["secrets"]
        verbs: ["get", "list", "watch", "create", "update", "patch", "delete"]
      - apiGroups: [""]
        resources: ["namespaces"]
        verbs: ["get", "list", "watch"]
  - name: kyverno-patch-deployments
    fullnameOverride: kyverno-patch-deployments
    rules:
      - apiGroups: ["apps"]
        resources: ["deployments", "deployments/scale"]
        verbs: ["get", "list", "watch", "update", "patch"]
ClusterRoleBindings:
 - name: kyverno-generate-secrets-background
   fullnameOverride: kyverno-generate-secrets-background
   roleRef:
     kind: ClusterRole
     name: kyverno-generate-secrets
     apiGroup: rbac.authorization.k8s.io
   subjects:
     - kind: ServiceAccount
       name: kyverno-background-controller
       namespace: kyverno-system
 - name: kyverno-generate-secrets-admission
   fullnameOverride: kyverno-generate-secrets-admission
   roleRef:
     kind: ClusterRole
     name: kyverno-generate-secrets
     apiGroup: rbac.authorization.k8s.io
   subjects:
     - kind: ServiceAccount
       name: kyverno-admission-controller
       namespace: kyverno-system
 - name: kyverno-patch-deployments-background
   fullnameOverride: kyverno-patch-deployments-background
   roleRef:
     kind: ClusterRole
     name: kyverno-patch-deployments
     apiGroup: rbac.authorization.k8s.io
   subjects:
     - kind: ServiceAccount
       name: kyverno-background-controller
       namespace: kyverno-system
 - name: kyverno-patch-deployments-admission
   fullnameOverride: kyverno-patch-deployments-admission
   roleRef:
     kind: ClusterRole
     name: kyverno-patch-deployments
     apiGroup: rbac.authorization.k8s.io
   subjects:
     - kind: ServiceAccount
       name: kyverno-admission-controller
       namespace: kyverno-system

