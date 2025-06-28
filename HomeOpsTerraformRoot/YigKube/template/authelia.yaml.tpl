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
    level: info
  theme: dark
  webauthn:
    disable: false
    enable_passkey_login: true
    display_name: "Yig"
  session:
    # FIXME: REDIS
    #encryption_key:
    #  value: ${oidc_session_enc_key}
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
      - domain: "magic.${ingress_domain}"
        subjects:
          - group: "${ingress_base_group}"
        policy: two_factor # entry only exists to force Authelia into allowing 2FA management
      - domain: "echo.${ingress_domain}"
        policy: bypass
      - domain: "ha.${ingress_domain}"
        policy: bypass
      - domain: "authelia.${ingress_domain}"
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
        value: ${ldap_pass}
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
      value: ${storage_enc_key}
    local:
      enabled: true
  notifier:
    # TODO: enable smtp
    filesystem:
      enabled: true
  identity_providers:
    oidc:
      enabled: true
      jwks:
        - key_id: authelia-idp-key-1
          algorithm: RS256
          use: sig
          key: 
            value: |
              ${indent(14, oidc_private_key)}
      claims_policies:
        oidccp_profile_in_id_token: # Authelia by default behaves like Keycloak and not may claims are available in id_token
          id_token:
            - email
            - name
            - groups
            - preferred_username
      clients:
        # TODO: this should be templatable and not part of main configMap
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
            value: ${oidc_grafana_client_secret} # FIXME: use secrets
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


# TODO: Duo
