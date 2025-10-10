---
# HA doesn't like YAML for MQTT broker anymore ;______;
#broker: "${broker}"
#discovery: true
#discovery_prefix: "homeassistant"
#password: "${password}"
#username: "${username}"

sensor:
# BUG: this code is shit
%{ for device_id, device in rtl433_devices["tfa_marbella"] ~}
  - name: "Temperature"
    unique_id: "rtl433_tfa_303181_${device.topic_id}_${device.name}_temperature"
    object_id: "rtl433_tfa_303181_${device.topic_id}_${device.name}_temperature"
    state_topic: "rtl_433/devices/TFA-Marbella/${device.topic_id}/temperature_C"
    unit_of_measurement: "°C"
    device_class: "temperature"
    state_class: "measurement"
    expire_after: 300
    device:
      identifiers: ["tfa_marbella_${device.topic_id}"]
      manufacturer: "TFA"
      model: "30.3239.02"
      name: "TFA ${device.alias}"
%{ endfor ~}
%{ for device_id, device in rtl433_devices["tfa_303181"] ~}
  - name: "Temperature"
    unique_id: "rtl433_tfa_303181_${device.topic_id}_${device.name}_temperature"
    object_id: "rtl433_tfa_303181_${device.topic_id}_${device.name}_temperature"
    state_topic: "rtl_433/devices/Klimalogg-Pro/${device.topic_id}/temperature_C"
    unit_of_measurement: "°C"
    device_class: "temperature"
    state_class: "measurement"
    expire_after: 300
    device:
      identifiers: ["tfa_klimalogg_pro_${device.topic_id}"]
      manufacturer: "TFA"
      model: "30.3181.IT"
      name: "TFA ${device.alias}"
%{ endfor ~}
%{ for device_id, device in rtl433_devices["tfa_303180"] ~}
  - name: "Temperature"
    unique_id: "rtl433_tfa_303180_${device.topic_id}_${device.name}_temperature"
    object_id: "rtl433_tfa_303180_${device.topic_id}_${device.name}_temperature"
    state_topic: "rtl_433/devices/Klimalogg-Pro/${device.topic_id}/temperature_C"
    unit_of_measurement: "°C"
    device_class: "temperature"
    state_class: "measurement"
    expire_after: 300
    device:
      identifiers: ["tfa_klimalogg_pro_${device.topic_id}"]
      manufacturer: "TFA"
      model: "30.3180.IT"
      name: "TFA ${device.alias}"
  - name: "Humidity"
    unique_id: "rtl433_tfa_303180_${device.topic_id}_${device.name}_humidity"
    object_id: "rtl433_tfa_303180_${device.topic_id}_${device.name}_humidity"
    state_topic: "rtl_433/devices/Klimalogg-Pro/${device.topic_id}/humidity"
    unit_of_measurement: "%"
    device_class: "humidity"
    state_class: "measurement"
    expire_after: 300
    device:
      identifiers: ["tfa_klimalogg_pro_${device.topic_id}"]
      manufacturer: "TFA"
      model: "30.3180.IT"
      name: "TFA ${device.alias}"
%{ endfor ~}
%{ for device_id, device in rtl433_devices["tfa_view_wind"] ~}
  - name: "Temperature"
    unique_id: "rtl433_tfa_view_${device.topic_id}_${device.name}_temperature"
    object_id: "rtl433_tfa_view_${device.topic_id}_${device.name}_temperature"
    state_topic: "rtl_433/devices/LaCrosse-BreezePro/${device.topic_id}/temperature_C"
    unit_of_measurement: "°C"
    device_class: "temperature"
    state_class: "measurement"
    expire_after: 600
    device:
      identifiers: ["tfa_view_wind_${device.topic_id}"]
      manufacturer: "TFA"
      model: "30.3803.02"
      name: "TFA View ${device.alias}"
  - name: "Humidity"
    unique_id: "rtl433_tfa_view_${device.topic_id}_${device.name}_humidity"
    object_id: "rtl433_tfa_view_${device.topic_id}_${device.name}_humidity"
    state_topic: "rtl_433/devices/LaCrosse-BreezePro/${device.topic_id}/humidity"
    unit_of_measurement: "%"
    device_class: "humidity"
    state_class: "measurement"
    expire_after: 600
    device:
      identifiers: ["tfa_view_wind_${device.topic_id}"]
      manufacturer: "TFA"
      model: "30.3803.02"
      name: "TFA View ${device.alias}"
  - name: "Wind Average Speed"
    unique_id: "rtl433_tfa_view_${device.topic_id}_${device.name}_wind_avg_speed"
    object_id: "rtl433_tfa_view_${device.topic_id}_${device.name}_wind_avg_speed"
    state_topic: "rtl_433/devices/LaCrosse-BreezePro/${device.topic_id}/wind_avg_km_h"
    unit_of_measurement: "km/h"
    device_class: "wind_speed"
    state_class: "measurement"
    expire_after: 600
    device:
      identifiers: ["tfa_view_wind_${device.topic_id}"]
      manufacturer: "TFA"
      model: "30.3803.02"
      name: "TFA View ${device.alias}"
  - name: "Wind Direction"
    unique_id: "rtl433_tfa_view_${device.topic_id}_${device.name}_wind_dir"
    object_id: "rtl433_tfa_view_${device.topic_id}_${device.name}_wind_dir"
    state_topic: "rtl_433/devices/LaCrosse-BreezePro/${device.topic_id}/wind_dir_deg"
    unit_of_measurement: "°"
    device_class: "wind_direction"
    state_class: "measurement"
    expire_after: 600
    device:
      identifiers: ["tfa_view_wind_${device.topic_id}"]
      manufacturer: "TFA"
      model: "30.3803.02"
      name: "TFA View ${device.alias}"
%{ endfor ~}
%{ for device_id, device in rtl433_devices["tfa_view_rain"] ~}
  - name: "Rain"
    unique_id: "rtl433_tfa_view_${device.topic_id}_${device.name}_rain"
    object_id: "rtl433_tfa_view_${device.topic_id}_${device.name}_rain"
    state_topic: "rtl_433/devices/LaCrosse-R3/${device.topic_id}/rain_mm"
    unit_of_measurement: "mm"
    device_class: "precipitation"
    state_class: "total"
    expire_after: 600
    device:
      identifiers: ["tfa_view_rain_${device.topic_id}"]
      manufacturer: "TFA"
      model: "30.3802.02"
      name: "TFA View ${device.alias}"
  - name: "Rain2"
    unique_id: "rtl433_tfa_view_${device.topic_id}_${device.name}_rain2"
    object_id: "rtl433_tfa_view_${device.topic_id}_${device.name}_rain2"
    state_topic: "rtl_433/devices/LaCrosse-R3/${device.topic_id}/rain2_mm"
    unit_of_measurement: "mm"
    device_class: "precipitation"
    state_class: "total"
    expire_after: 600
    device:
      identifiers: ["tfa_view_rain_${device.topic_id}"]
      manufacturer: "TFA"
      model: "30.3802.02"
      name: "TFA View ${device.alias}"
%{ endfor ~}


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
