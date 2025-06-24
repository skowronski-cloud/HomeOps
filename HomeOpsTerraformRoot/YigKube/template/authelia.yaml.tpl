---
# https://www.authelia.com/configuration/
replicaCount: 1

ingress:
  enabled: true
  certManager: true
  className: treaefik
  hosts:
    - host: authelia.${ingress_domain}
      paths: ["/"]
  traefikCRD:
    enabled: true
    entryPoints:
      - websecure
    tls:
      certResolver: yig-ca-issuer

configMap:
  log:
    level: debug
  theme: dark
  webauthn:
    disable: false
    enable_passkey_login: true
    display_name: "Yig"
  session:
    # FIXME: REDIS
    cookies: # this is what controls ingress domains!
      - domain: '${ingress_domain}'
        subdomain: 'authelia'
        authelia_url: 'https://authelia.${ingress_domain}'
        default_redirection_url: 'https://authelia.${ingress_domain}/login'
        name: 'authelia_session'
        same_site: 'lax'
        inactivity: '1h'
        expiration: '1d'
        remember_me: '7d'
  access_control:
    rules:
      - domain: "echo.${ingress_domain}"
        policy: bypass
      - domain: "ha.${ingress_domain}"
        policy: bypass
      - domain: "authelia.${ingress_domain}"
        policy: bypass
      - domain: "*.${ingress_domain}"
        subjects:
          - group: "yig-ingress-users"
        policy: one_factor
  authentication_backend:
    ldap:
      enabled: true
      address: ${ldap_url}
      base_dn: ${ldap_basedn}
      user: ${ldap_user}
      password: 
        value: ${ldap_pass}
      users_filter: ${ldap_filter}
      tls:
        skip_verify: true
      # Synology Directory Server is not exactly AD...
      additional_users_dn: ''
      additional_groups_dn: ''
    password_reset:
      disable: true
  storage:
    encryption_key: 
      value: ${storage_enc_key}
    local:
      enabled: true
  notifier:
    # TODO: enable smtp
    filesystem:
      enabled: true


# TODO: Duo
