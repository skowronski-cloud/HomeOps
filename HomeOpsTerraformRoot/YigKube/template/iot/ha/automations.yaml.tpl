---
- alias: MQTT homeassistant/retained/electrolux_waterlow
  id: manual_mqtt_retained_electrolux_waterlow
  description: ""
  triggers:
    - trigger: state
      entity_id:
        - binary_sensor.wellbeing_oczyszczacz_powietrza_watertraylevellow
  conditions: []
  actions:
    - action: mqtt.publish
      metadata: {}
      data:
        evaluate_payload: false
        qos: "0"
        retain: true
        topic: homeassistant/retained/electrolux_waterlow
        payload: >-
          {{
          states('binary_sensor.wellbeing_oczyszczacz_powietrza_watertraylevellow')
          }}
  mode: single
- alias: MQTT homeassistant/retained/electrolux_humidification
  id: manual_mqtt_retained_electrolux_humidification
  description: ""
  triggers:
    - trigger: state
      entity_id:
        - binary_sensor.wellbeing_oczyszczacz_powietrza_humidification
  conditions: []
  actions:
    - action: mqtt.publish
      metadata: {}
      data:
        evaluate_payload: false
        qos: "0"
        retain: true
        topic: homeassistant/retained/electrolux_humidification
        payload: >-
          {{
          states('binary_sensor.wellbeing_oczyszczacz_powietrza_humidification')
          }}
  mode: single
- alias: MQTT homeassistant/retained/electrolux_humidity
  id: manual_mqtt_retained_electrolux_humidity
  description: ""
  triggers:
    - trigger: state
      entity_id:
        - sensor.wellbeing_oczyszczacz_powietrza_humidity
  conditions: []
  actions:
    - action: mqtt.publish
      metadata: {}
      data:
        evaluate_payload: false
        qos: "0"
        retain: true
        topic: homeassistant/retained/electrolux_humidity
        payload: >-
          {{
          states('sensor.wellbeing_oczyszczacz_powietrza_humidity')
          }}
  mode: single
- alias: MQTT homeassistant/retained/electrolux_humiditytarget
  id: manual_mqtt_retained_electrolux_humiditytarget
  description: ""
  triggers:
    - trigger: state
      entity_id:
        - sensor.wellbeing_oczyszczacz_powietrza_humiditytarget
  conditions: []
  actions:
    - action: mqtt.publish
      metadata: {}
      data:
        evaluate_payload: false
        qos: "0"
        retain: true
        topic: homeassistant/retained/electrolux_humiditytarget
        payload: >-
          {{
          states('sensor.wellbeing_oczyszczacz_powietrza_humiditytarget')
          }}
  mode: single



