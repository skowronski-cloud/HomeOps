---
# https://docs.infrahub.app/reference/configuration
Secrets:
  - name: infrahub-env
    fullnameOverride: infrahub-env
    keys:
      INFRAHUB_DB_PASSWORD: ${ infrahub_neo4j_password }
      INFRAHUB_BROKER_PASSWORD: ${ infrahub_rabbitmq_pass }
      INFRAHUB_CACHE_PASSWORD: ${ infrahub_redis_pass }
      INFRAHUB_INITIAL_ADMIN_PASSWORD: ${ infrahub_initial_admin_password }
      INFRAHUB_INITIAL_ADMIN_TOKEN: ${ infrahub_initial_admin_token }
      INFRAHUB_SECURITY_SECRET_KEY: ${ infrahub_security_secret_key }
