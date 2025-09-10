---
#"vernemq.conf.local": |
"vernemq.conf": |
  ## netsplit
  allow_register_during_netsplit = on
  allow_publish_during_netsplit = on
  allow_subscribe_during_netsplit = on
  allow_unsubscribe_during_netsplit = on

  ## diversity
  plugins.vmq_diversity = off
  vmq_diversity.auth_redis.enabled = off

  ## authentication
  allow_anonymous = off
  plugins.vmq_passwd = off # using env vars

  ## authorization
  plugins.vmq_acl = on
  vmq_acl.acl_file = /etc/vernemq/acl/vmq.acl
  
  ## timers
  persistent_client_expiration = 1w
