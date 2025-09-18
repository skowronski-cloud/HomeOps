---
db_url: !secret psql_string
#auto_purge: false
db_retry_wait: 15 # Wait 15 seconds before retrying
purge_keep_days: 3650 # 10y
exclude:
  domains:
    - automation
    - updater
  entity_globs: []
  entities:
    - sun.sun
    - sensor.last_boot
    - sensor.date
  event_types:
    - call_service # Don't record service calls