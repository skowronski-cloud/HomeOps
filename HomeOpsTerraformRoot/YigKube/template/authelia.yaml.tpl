---
# https://www.authelia.com/configuration/
# https://artifacthub.io/packages/helm/authelia/authelia?modal=values
pod:
  replicas: ${replicas}

ingress:
  enabled: true
  certManager: true
  className: treaefik
  traefikCRD:
    enabled: true
    entryPoints:
      - websecure
    tls:
      certResolver: yig-ca-issuer

secret:
  additionalSecrets:
    authelia-secrets: {}
    oidc-grafana-client: {}

configMap:
  log:
    level: info
  theme: dark
  webauthn:
    disable: false
    enable_passkey_login: true
    display_name: "Yig"
  duo_api:
    enabled: true
    hostname: ${duo_api_hostname}
    integration_key: ${duo_integration_key}
    secret:
      secret_name: authelia-secrets
    enable_self_enrollment: true
  session:
    encryption_key:
      secret_name: authelia-secrets
    redis:
      enabled: true
      deploy: true
      #host: authelia-redis-master.traefik-system.svc.cluster.local
      host: authelia-redis
      port: 26379
      password:
        secret_name: authelia-secrets
      high_availability:
        enabled: true
        password:
          secret_name: authelia-secrets
        sentinel_name: mymaster
    cookies: # this is what controls ingress domains!
      - domain: '${ingress_domain}'
        subdomain: 'authelia'
        authelia_url: 'https://authelia.${ingress_domain}'
        default_redirection_url: 'https://authelia.${ingress_domain}/login'
        name: 'authelia_session'
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
      - domain: "hfm.${ingress_domain}"
        policy: bypass
      - domain: "fridge.${ingress_domain}"
        policy: bypass
      - domain: "*.${ingress_domain}"
        subjects:
          - group: "${ingress_base_group}"
        policy: two_factor
  authentication_backend:
    ldap:
      enabled: true
      address: ${ldap_url}
      base_dn: ${ldap_basedn}
      user: ${ldap_user}
      password: 
        secret_name: authelia-secrets
      users_filter: ${ldap_filter}
      tls:
        skip_verify: true
      # Synology Directory Server is not exactly AD...
      additional_users_dn: ''
      additional_groups_dn: ''
      attributes:
        username: 'sAMAccountName'
        mail: 'mail'
    password_reset:
      disable: true
  storage:
    encryption_key: 
      secret_name: authelia-secrets
    local:
      enabled: true
  notifier:
    filesystem:
      enabled: false
    smtp:
      enabled: true
      address: submission://${smtp_host}:${smtp_port}
      sender: "Authelia <${smtp_user}>"
      subject: '[Authelia] {title}'
      username: ${smtp_user}
      password: 
        secret_name: authelia-secrets
  identity_validation:
    reset_password:
      secret:
        secret_name: authelia-secrets
  identity_providers:
    oidc:
      enabled: true
      hmac_secret: 
        secret_name: authelia-secrets
      jwks:
        - key_id: authelia-idp-key-1
          algorithm: RS256
          use: sig
          key: 
            path: /secrets/authelia-secrets/oidc-jwk.RS256.pem
      claims_policies:
        oidccp_profile_in_id_token: # https://www.authelia.com/integration/openid-connect/grafana/
          id_token:
            - email
            - name
            - groups
            - preferred_username
      clients:
        - client_id: ${oidc_grafana_client_id}
          client_name: "Yig Grafana"
          public: false
          pkce_challenge_method: S256
          response_types:
            - 'code'
          grant_types:
            - 'authorization_code'
          access_token_signed_response_alg: 'none'
          userinfo_signed_response_alg: 'none'
          token_endpoint_auth_method: 'client_secret_basic'
          client_secret:
            path: /secrets/oidc-grafana-client/client-secret
          scopes:
            - openid
            - profile
            - email
            - groups
          claims_policy: oidccp_profile_in_id_token
          redirect_uris: 
            - https://grafana.${ingress_domain}/login/generic_oauth

persistence:
  enabled: true
  accessModes:
    - ReadWriteMany

redis:
  enabled: true
  architecture: replication
  replica:
    replicaCount: 2
  sentinel:
    enabled: true
    masterSet: mymaster