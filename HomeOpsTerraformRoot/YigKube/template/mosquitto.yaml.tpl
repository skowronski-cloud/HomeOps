---
mosquitto:
  users: |-
%{ for name,cfg in mqtt_accounts ~}
    ${cfg.user}:${cfg.hash}
%{ endfor ~}
  acls: |-
%{ for name,cfg in mqtt_accounts ~}
    user ${cfg.user}
    topic readwrite ${name}/#
%{ for acl in cfg.acl ~}
    ${acl}
%{ endfor ~}

%{ endfor ~}