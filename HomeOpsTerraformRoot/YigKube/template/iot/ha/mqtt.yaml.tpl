---
# HA doesn't like YAML for MQTT broker anymore ;______;
#broker: "${broker}"
#discovery: true
#discovery_prefix: "homeassistant"
#password: "${password}"
#username: "${username}"

sensor:
%{ for device_id, device in qingping_devices ~}
%{ for entity_id, entity in qingping_mqtt_payload_map ~}
%{ if contains(["pm25","pm10"], entity_id) && !device.supportsPM ~}%{ else ~}
  - name: "${entity.friendly_name}"
    unique_id: "qingping_${device_id}_${entity_id}"
    object_id: "qingping_${device_id}_${entity_id}"
    state_topic: "qingping/${device.mac}/up"
%{ if device.binary ~}
    encoding: ""
    value_template: >
      {# https://github.com/niklasarnitz/qingping-co2-temp-rh-sensor-mqtt-parser/blob/master/src/parser.ts #}
      {% set metric = "${entity.mqtt_key}" %}
      {% set b = value|list %}{% set L = b|length %}
      {% set p0 = 5 if (L>=5 and b[0]==0x43 and b[1]==0x47) else 0 %}
      {% set ns = namespace(i=p0, out=None) %}
      {% for _ in range(0,2048) %}
        {% if ns.i + 3 > L or ns.out is not none %}{% break %}{% endif %}
        {% set k = b[ns.i] %}
        {% set n = b[ns.i+1] + b[ns.i+2]*256 %}
        {% set v = ns.i + 3 %}
        {% if k == 0x14 and v + 12 <= L %}
          {% set s0=b[v+4] %}{% set s1=b[v+5] %}{% set s2=b[v+6] %}
          {% set s3=b[v+7] %}{% set s4=b[v+8] %}{% set s5=b[v+9] %}
          {% set comb = s0 + s1*256 + s2*65536 %}
          {% set t10  = (comb // 4096) % 4096 %}
          {% set rh10 = comb % 4096 %}
          {% set temp_c = (t10 - 500) / 10 %}
          {% set rh_pct = rh10 / 10 %}
          {% set co2_ppm  = s3 + s4*256 %}
          {% set batt_pct = s5 %}
          {% if   metric == 'temperature' %}{% set ns.out = temp_c   %}
          {% elif metric == 'humidity'    %}{% set ns.out = rh_pct   %}
          {% elif metric == 'co2'         %}{% set ns.out = co2_ppm  %}
          {% elif metric == 'battery'     %}{% set ns.out = batt_pct %}
          {% endif %}
        {% endif %}
        {% set ns.i = ns.i + 3 + n %}
      {% endfor %}

      {{ ns.out if ns.out is not none else (states(this.entity_id) | float(0)) }}
%{ else ~}
    value_template: "{{ value_json.sensorData[0].${entity.mqtt_key}.value }}"
%{ endif ~}
    unit_of_measurement: "${entity.unit}"
    device_class: "${entity.device_class}"
    state_class: "${entity.state_class}"
    expire_after: ${entity.expire_after}
    device:
      identifiers: ["qingping_${device.mac}"]
      manufacturer: "Qingping"
      model: "${device.model}"
      name: "Qingping ${device.alias}"
      connections:
        - - "mac"
          - "${device.mac}"
%{ endif ~}
%{ endfor ~}
%{ endfor ~}
