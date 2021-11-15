terraform {
  required_providers {
    zpa = {
      source  = "zscaler.com/zpa/zpa"
      version = "1.0.0"
    }
  }
}

# Populate the locals
locals {
  ## ZPA Authentication Information
  ## See: https://help.zscaler.com/zpa/getting-started-zpa-api 
  client_id        = "<ZPA_CLIENT_ID>"
  client_secret    = "<ZPA_CLIENT_SECRET>"
  customerid      = "<ZPA_CUSTOMER_ID>"

  ## IoT Edge Information
  edge_name       = "402-201745002"
  edge_fqdn       = "402-201745002.local"
  #edge_ip         = ""
  edge_latitude   = "0.1807"
  edge_longitude  = "78.4678"
  edge_location   = "Quito, Ecuador"
  edge_country    = "EC"
}

# Setup ZPA Tenant
provider "zpa" {
  client_id        = local.client_id
  client_secret    = local.client_secret
  customerid      = local.customerid
}

# Create App Connector Group for IoT Edge
resource "zpa_app_connector_group" "iot_edge_connector_group" {
  name                          = join(" ", [local.edge_name, "App Connector Group"])
  description                   = join(" ", [local.edge_name, "App Connector Group -", local.edge_location])
  enabled                       = true
  country_code                  = local.edge_country
  latitude                      = local.edge_latitude
  longitude                     = local.edge_longitude
  location                      = local.edge_location
  upgrade_day                   = "SUNDAY"
  upgrade_time_in_secs          = "66600"
  override_version_profile      = true
  version_profile_id            = 0
  dns_query_type                = "IPV4"
}



data "zpa_enrollment_cert" "connector" {
    name = "Connector"
}

// Create Provisioning Key for App Connector Group
resource "zpa_provisioning_key" "iot_edge_key" {
  name             = join(" ", [local.edge_name, "Provisioning Key"])
  association_type = "CONNECTOR_GRP"
  max_usage        = "10"
  enrollment_cert_id = data.zpa_enrollment_cert.connector.id
  zcomponent_id = zpa_app_connector_group.iot_edge_connector_group.id
}

// Create Application Segment
resource "zpa_application_segment" "iot_edge_application" {
  name             = local.edge_name
  description      = join(" ", [local.edge_name, "App Segment"])
  enabled          = true
  health_reporting = "NONE"
  bypass_type      = "NEVER"
  is_cname_enabled = true
  tcp_port_range {
    from = "22"
    to   = "22"
  }
  domain_names     = [local.edge_fqdn]
  segment_group_id = zpa_segment_group.iot_edge_app_group.id
  server_groups {
    id = [zpa_server_group.iot_edge_servers.id]
  }
}

// Create Server Group
resource "zpa_server_group" "iot_edge_servers" {
  name              = join(" ", [local.edge_name, "Servers"])
  description       = join(" ", [local.edge_name, "Servers"])
  enabled           = true
  dynamic_discovery = false
  app_connector_groups {
    id = [zpa_app_connector_group.iot_edge_connector_group.id]
  }
  servers {
    id = [zpa_application_server.iot_edge_app_server.id]
  }
}

// Create Application
resource "zpa_application_server" "iot_edge_app_server" {
  name        = join(" ", [local.edge_name, "App Server"])
  description = join(" ", [local.edge_name, "App Server"])
  address     = local.edge_fqdn
  enabled     = true
}

// Create Segment Group
resource "zpa_segment_group" "iot_edge_app_group" {
  name            = join(" ", [local.edge_name, "Segment Group"])
  description     = join(" ", [local.edge_name, "Segment Group"])
  enabled         = true
  policy_migrated = true
}

output "provisioning_key" {
  value = zpa_provisioning_key.iot_edge_key.provisioning_key
}



