locals {
  victoria_logs_vmauth_config = yamlencode({
    users = [
      {
        username = var.victoria_logs.writer_username
        password = var.victoria_logs.writer_password
        url_map = [{
          src_paths  = ["/insert/.*"]
          url_prefix = "http://victoria-logs:9428/"
        }]
      },
      {
        username = var.victoria_logs.reader_username
        password = var.victoria_logs.reader_password
        url_map = [
          {
            src_paths  = ["/select/.*"]
            url_prefix = "http://victoria-logs:9428/"
          },
          {
            src_paths                  = ["/internal/metrics"]
            drop_src_path_prefix_parts = 1
            url_prefix                 = "http://victoria-logs:9428/"
          }
        ]
      },
      {
        bearer_token = var.victoria_logs.ingress_proxy_token
        url_map = [{
          src_paths  = ["/select/.*"]
          url_prefix = "http://victoria-logs:9428/"
        }]
      }
    ]
  })
}

resource "tls_private_key" "victoria_logs" {
  algorithm   = "ECDSA"
  ecdsa_curve = "P256"
}

resource "tls_cert_request" "victoria_logs" {
  private_key_pem = tls_private_key.victoria_logs.private_key_pem

  dns_names = [
    "victoria-logs.${var.ingress_domain}",
    "victoria-logs.logging.svc",
    "victoria-logs.logging.svc.cluster.local"
  ]
  ip_addresses = [var.victoria_logs_config.host]

  subject {
    common_name  = "victoria-logs.${var.ingress_domain}"
    organization = "HomeOps"
  }
}

resource "tls_locally_signed_cert" "victoria_logs" {
  cert_request_pem   = tls_cert_request.victoria_logs.cert_request_pem
  ca_cert_pem        = base64decode(var.yig_ca_crt)
  ca_private_key_pem = base64decode(var.yig_ca_key)

  validity_period_hours = 8760
  early_renewal_hours   = 720
  allowed_uses = [
    "digital_signature",
    "server_auth"
  ]
}

resource "synology_filestation_folder" "victoria_logs_data" {
  path           = "${var.victoria_logs_config.synology_project_path}/data"
  create_parents = true
}

# Container-project secrets currently flatten unknown values to empty strings
# during planning. Upload the generated TLS material separately so it can remain
# unknown until apply, then mount the files read-only into both services.
resource "synology_filestation_file" "victoria_logs_tls_cert" {
  path           = "${var.victoria_logs_config.synology_project_path}/tls.crt"
  content        = tls_locally_signed_cert.victoria_logs.cert_pem
  create_parents = true
  overwrite      = true
}

resource "synology_filestation_file" "victoria_logs_tls_key" {
  path           = "${var.victoria_logs_config.synology_project_path}/tls.key"
  content        = tls_private_key.victoria_logs.private_key_pem
  create_parents = true
  overwrite      = true
}

resource "synology_container_project" "victoria_logs" {
  name       = "victoria-logs"
  share_path = var.victoria_logs_config.synology_project_path
  run        = true

  services = {
    "victoria-logs" = {
      image        = "victoriametrics/victoria-logs:${var.ver_docker_victoria_logs}"
      init         = true
      mem_limit    = var.victoria_logs_config.victoria_logs_memory_limit
      restart      = "unless-stopped"
      cap_drop     = ["ALL"]
      security_opt = ["no-new-privileges:true"]

      command = [
        "-storageDataPath=/victoria-logs-data",
        "-retentionPeriod=${var.victoria_logs_config.retention_period}",
        "-retention.maxDiskSpaceUsageBytes=${var.victoria_logs_config.retention_max_disk_space_usage_bytes}",
        "-storage.minFreeDiskSpaceBytes=${var.victoria_logs_config.storage_min_free_disk_space_bytes}",
        "-memory.allowedPercent=${var.victoria_logs_config.memory_allowed_percent}",
        "-loggerFormat=json",
        "-syslog.listenAddr.tcp=:${var.victoria_logs_config.syslog_port}",
        "-syslog.tls=false",
        "-syslog.tlsCertFile=",
        "-syslog.tlsKeyFile=",
        "-syslog.useRemoteIP.tcp=true",
        "-syslog.listenAddr.tcp=:${var.victoria_logs_config.syslog_tls_port}",
        "-syslog.tls=true",
        "-syslog.tlsCertFile=/run/secrets/tls.crt",
        "-syslog.tlsKeyFile=/run/secrets/tls.key",
        "-syslog.useRemoteIP.tcp=true",
        "-syslog.listenAddr.udp=:${var.victoria_logs_config.syslog_port}",
        "-syslog.useRemoteIP.udp=true"
      ]

      ports = [
        {
          target    = var.victoria_logs_config.syslog_port
          published = tostring(var.victoria_logs_config.syslog_port)
          protocol  = "tcp"
        },
        {
          target    = var.victoria_logs_config.syslog_port
          published = tostring(var.victoria_logs_config.syslog_port)
          protocol  = "udp"
        },
        {
          target    = var.victoria_logs_config.syslog_tls_port
          published = tostring(var.victoria_logs_config.syslog_tls_port)
          protocol  = "tcp"
        }
      ]

      logging = {
        driver = "json-file"
        options = {
          max-file = "5"
          max-size = "20m"
        }
      }

      volumes = [
        {
          type      = "bind"
          target    = "/victoria-logs-data"
          source    = "${var.victoria_logs_config.synology_project_real_path}/data"
          read_only = false
          bind = {
            create_host_path = false
          }
        },
        {
          type      = "bind"
          target    = "/run/secrets/tls.crt"
          source    = "${var.victoria_logs_config.synology_project_real_path}/tls.crt"
          read_only = true
          bind = {
            create_host_path = false
          }
        },
        {
          type      = "bind"
          target    = "/run/secrets/tls.key"
          source    = "${var.victoria_logs_config.synology_project_real_path}/tls.key"
          read_only = true
          bind = {
            create_host_path = false
          }
        }
      ]
    }

    "vmauth" = {
      image        = "victoriametrics/vmauth:${var.ver_docker_vmauth}"
      init         = true
      mem_limit    = var.victoria_logs_config.vmauth_memory_limit
      restart      = "unless-stopped"
      cap_drop     = ["ALL"]
      security_opt = ["no-new-privileges:true"]

      command = [
        "-auth.config=/run/secrets/auth.yml",
        "-httpListenAddr=:${var.victoria_logs_config.api_port}",
        "-httpInternalListenAddr=:8428",
        "-httpAuthHeader=Authorization",
        "-httpAuthHeader=X-VL-Auth",
        "-tls",
        "-tlsCertFile=/run/secrets/tls.crt",
        "-tlsKeyFile=/run/secrets/tls.key",
        "-removeXFFHTTPHeaderValue",
        "-http.header.hsts=max-age=31536000; includeSubDomains",
        "-loggerFormat=json"
      ]

      depends_on = {
        "victoria-logs" = {
          condition = "service_started"
          restart   = true
        }
      }

      ports = [{
        target    = var.victoria_logs_config.api_port
        published = tostring(var.victoria_logs_config.api_port)
        protocol  = "tcp"
      }]

      secrets = [
        {
          source = "victoria_logs_vmauth_config"
          target = "/run/secrets/auth.yml"
          mode   = "0444"
        }
      ]

      volumes = [
        {
          type      = "bind"
          target    = "/run/secrets/tls.crt"
          source    = "${var.victoria_logs_config.synology_project_real_path}/tls.crt"
          read_only = true
          bind = {
            create_host_path = false
          }
        },
        {
          type      = "bind"
          target    = "/run/secrets/tls.key"
          source    = "${var.victoria_logs_config.synology_project_real_path}/tls.key"
          read_only = true
          bind = {
            create_host_path = false
          }
        }
      ]

      logging = {
        driver = "json-file"
        options = {
          max-file = "5"
          max-size = "20m"
        }
      }
    }
  }

  secrets = {
    "victoria_logs_vmauth_config" = {
      name    = "victoria_logs_vmauth_config"
      file    = "victoria_logs_vmauth_config"
      content = local.victoria_logs_vmauth_config
    }
  }

  depends_on = [
    synology_filestation_folder.victoria_logs_data,
    synology_filestation_file.victoria_logs_tls_cert,
    synology_filestation_file.victoria_logs_tls_key
  ]

  lifecycle {
    replace_triggered_by = [
      synology_filestation_file.victoria_logs_tls_cert,
      synology_filestation_file.victoria_logs_tls_key
    ]
  }
}
