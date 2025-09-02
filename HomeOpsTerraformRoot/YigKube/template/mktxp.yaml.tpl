---
image:
  tag: ${ image_version }
  pullPolicy: IfNotPresent

ingress:
  main:
    enabled: true
    ingressClassName: "traefik"
    annotations: {}
    hosts:
      - host: mktxp.${ingress_domain}
        paths:
          - path: /
            pathType: Prefix
persistence: {}

configmap:
  config:
    enabled: true
    data:
      mktxp.conf: |
        [hEX-main]
            enabled = True
            hostname = ${ mikrotik_monitoring_router_ip }
            port = 8728
            username = ${ mikrotik_monitoring_account.user }
            password = ${ mikrotik_monitoring_account.password }

            use_ssl = False 
            ssl_certificate_verify = False
            
            installed_packages = True       # Installed packages
            dhcp = True                     # DHCP general metrics
            dhcp_lease = True               # DHCP lease metrics

            connections = True              # IP connections metrics
            connection_stats = False        # Open IP connections metrics

            pool = True                     # Pool metrics
            interface = True                # Interfaces traffic metrics

            firewall = True                 # IPv4 Firewall rules traffic metrics
            ipv6_firewall = False           # IPv6 Firewall rules traffic metrics
            ipv6_neighbor = False           # Reachable IPv6 Neighbors

            poe = False                     # POE metrics
            monitor = True                  # Interface monitor metrics
            netwatch = True                 # Netwatch metrics
            public_ip = True                # Public IP metrics
            route = True                    # Routes metrics
            wireless = True                 # WLAN general metrics
            wireless_clients = True         # WLAN clients metrics
            capsman = True                  # CAPsMAN general metrics
            capsman_clients = True          # CAPsMAN clients metrics

            user = True                     # Active Users metrics
            queue = True                    # Queues metrics

            remote_dhcp_entry = None        # An MKTXP entry for remote DHCP info resolution (capsman/wireless)

            use_comments_over_names = False  # when available, forces using comments over the interfaces names

            netwatch_name_label = "name" # pend https://github.com/akpw/mktxp/pull/264

            check_for_updates = True        # check for available ROS updates

      _mktxp.conf: |
        [MKTXP]
          port = 49090
          socket_timeout = 2

          initial_delay_on_failure = 120
          max_delay_on_failure = 900
          delay_inc_div = 5

          bandwidth = True               # Turns metrics bandwidth metrics collection on / off
          bandwidth_test_interval = 3600   # Interval for colllecting bandwidth metrics
          minimal_collect_interval = 5    # Minimal metric collection interval

          verbose_mode = True            # Set it on for troubleshooting

          fetch_routers_in_parallel = False   # Set to True if you want to fetch multiple routers parallel
          max_worker_threads = 5              # Max number of worker threads that can fetch routers (parallel fetch only)
          max_scrape_duration = 10            # Max duration of individual routers' metrics collection (parallel fetch only)
          total_max_scrape_duration = 30      # Max overall duration of all metrics collection (parallel fetch only)

metrics:
  enabled: true
  serviceMonitor:
    interval: 30s
    scrapeTimeout: 20s
    labels:
      release:  ${ metrics_label_release }
