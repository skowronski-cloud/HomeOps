initContainers:
- name: velero-plugin-for-aws
  image: velero/velero-plugin-for-aws:${ver_plugin_aws}
  volumeMounts:
    - mountPath: /target
      name: plugins


# This is set in the velero_resources helm_release, otheriwse CRD check kicks in before they are created
backupsEnabled: false
snapshotsEnabled: false

configuration:
  features: EnableCSI

deployNodeAgent: true # this is needed for data mover... https://github.com/vmware-tanzu/velero/issues/8576
nodeAgent:
  podVolumePath: /var/lib/k0s/kubelet/pods
  pluginVolumePath: /var/lib/k0s/kubelet/plugins