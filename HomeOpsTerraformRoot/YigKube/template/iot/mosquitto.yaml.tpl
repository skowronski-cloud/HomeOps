---
mosquitto:
  users: |-
%{ for name,cfg in mqtt_accounts ~}
    ${cfg.user}:${cfg.hash}
%{ endfor ~}
  acls: |-
    pattern write homeassistant/+/%u/+/config
%{ for name,cfg in mqtt_accounts ~}
    user ${cfg.user}
    topic readwrite ${name}/#
    topic readwrite homeassistant/+/${name}/+/config
%{ for acl in cfg.acl ~}
    ${acl}
%{ endfor ~}

%{ endfor ~}