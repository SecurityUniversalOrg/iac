provider "azurerm" {
  features {}
}

locals {
  resource_group_name = "example-waf-rg"
  location            = "East US"
  splunk_hec_url      = "https://your-splunk-instance.com:8088/services/collector"
  splunk_hec_token    = "your-splunk-hec-token"
}

resource "azurerm_resource_group" "example" {
  name     = local.resource_group_name
  location = local.location
}

resource "azurerm_virtual_network" "example" {
  name                = "example-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = local.location
  resource_group_name = azurerm_resource_group.example.name
}

resource "azurerm_subnet" "example" {
  name                 = "example-subnet"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_public_ip" "example" {
  name                = "example-pip"
  location            = local.location
  resource_group_name = azurerm_resource_group.example.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_application_gateway" "example" {
  name                = "example-waf"
  location            = local.location
  resource_group_name = azurerm_resource_group.example.name

  sku {
    name     = "WAF_v2"
    tier     = "WAF_v2"
    capacity = 2
  }

  gateway_ip_configuration {
    name      = "gateway-ip-config"
    subnet_id = azurerm_subnet.example.id
  }

  frontend_ip_configuration {
    name                 = "frontend-ip-config"
    public_ip_address_id = azurerm_public_ip.example.id
  }

  frontend_port {
    name = "frontend-port-ssl"
    port = 443
  }

  http_listener {
    name                           = "https-listener"
    frontend_ip_configuration_name = "frontend-ip-config"
    frontend_port_name             = "frontend-port-ssl"
    protocol                       = "Https"
    ssl_certificate_name           = azurerm_key_vault_certificate.example.name
  }

  backend_address_pool {
    name = "backend-address-pool"
  }

  backend_http_settings {
    name                  = "backend-http-settings"
    cookie_based_affinity = "Disabled"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 60
  }

  http_route_rule {
    name               = "https-route-rule"
    rule_type          = "Basic"
    http_listener_name = "https-listener"

    backend_address_pool {
      name = "backend-address-pool"
    }

    backend_http_settings {
      name = "backend-http-settings"
    }
  }

  waf_configuration {
    enabled                      = true
    firewall_mode                = "Prevention"
    rule_set_type                = "OWASP"
    rule_set_version             = "3.1"
    file_upload_limit_mb         = 100
    max_request_body_size_kb     = 128
    request_body_check           = true
    max_request_body_size_kb     = 128
    request_body_check           = true
  }
}

resource "azurerm_eventhub_namespace" "example" {
  name                = "example-eh-namespace"
  location            = local.location
  resource_group_name = azurerm_resource_group.example.name
  sku                 = "Standard"
}

resource "azurerm_eventhub" "example" {
  name                = "example-eventhub"
  namespace_name      = azurerm_eventhub_namespace.example.name
  resource_group_name = azurerm_resource_group.example.name
  partition_count     = 2
  message_retention   = 1
}

resource "azurerm_eventhub_namespace_authorization_rule" "example" {
  name                = "example-eh-rule"
  namespace_name      = azurerm_eventhub_namespace.example.name
  resource_group_name = azurerm_resource_group.example.name
  listen              = true
  send                = true
  manage              = false
}

resource "azurerm_monitor_diagnostic_setting" "example" {
  name                       = "example-diagnostic-setting"
  target_resource_id         = azurerm_application_gateway.example.id
  eventhub_authorization_rule_id = azurerm_eventhub_namespace_authorization_rule.example.id
  eventhub_name              = azurerm_eventhub.example.name

  log {
    category = "ApplicationGatewayFirewallLog"
    enabled  = true

    retention_policy {
      enabled = false
    }
  }

  log {
    category = "ApplicationGatewayAccessLog"
    enabled  = true

    retention_policy {
      enabled = false
    }
  }

  metric {
    category = "AllMetrics"
    enabled  = true

    retention_policy {
      enabled = false
    }
  }
}

resource "azurerm_storage_account" "example" {
  name                     = "examplewaflogs"
  resource_group_name      = azurerm_resource_group.example.name
  location                 = local.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_function_app" "example" {
  name                       = "example-waf-logs"
  location                   = local.location
  resource_group_name        = azurerm_resource_group.example.name
  app_service_plan_id        = azurerm_app_service_plan.example.id
  storage_account_name       = azurerm_storage_account.example.name
  storage_account_access_key = azurerm_storage_account.example.primary_access_key
  os_type                    = "linux"
  version                    = "~3"

  app_settings = {
    "FUNCTIONS_WORKER_RUNTIME" = "python"
    "SPLUNK_HEC_URL"           = local.splunk_hec_url
    "SPLUNK_HEC_TOKEN"         = local.splunk_hec_token
  }
}

resource "azurerm_app_service_plan" "example" {
  name                = "example-app-service-plan"
  location            = local.location
  resource_group_name = azurerm_resource_group.example.name
  kind                = "FunctionApp"
  reserved            = true

  sku {
    tier = "Dynamic"
    size = "Y1"
  }
}

resource "azurerm_function_app_slot" "example" {
  name                      = "production"
  function_app_name         = azurerm_function_app.example.name
  resource_group_name       = azurerm_resource_group.example.name
  app_service_plan_id       = azurerm_app_service_plan.example.id
  storage_account_name      = azurerm_storage_account.example.name
  storage_account_access_key = azurerm_storage_account.example.primary_access_key
}

resource "azurerm_key_vault" "example" {
  name                = "example-kv"
  location            = local.location
  resource_group_name = azurerm_resource_group.example.name
  sku_name            = "standard"
  tenant_id           = data.azurerm_client_config.current.tenant_id

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    key_permissions = [
      "get",
    ]

    secret_permissions = [
      "get",
    ]

    certificate_permissions = [
      "get",
    ]
  }

  soft_delete_retention_days = 7
  purge_protection_enabled   = false
}

resource "azurerm_key_vault_certificate" "example" {
  name         = "example-certificate"
  key_vault_id = azurerm_key_vault.example.id

  certificate {
    contents = filebase64("<PATH_TO_PFX_CERTIFICATE>")
    password = "<PFX_CERTIFICATE_PASSWORD>"
  }

  certificate_policy {
    issuer_parameters {
      name = "Unknown"
    }

    key_properties {
      exportable = true
      key_size   = 2048
      key_type   = "RSA"
      reuse_key  = true
    }

    secret_properties {
      content_type = "application/x-pkcs12"
    }

    x509_certificate_properties {
      key_usage = [
        "cRLSign",
        "dataEncipherment",
        "digitalSignature",
        "keyEncipherment",
        "keyAgreement",
        "keyCertSign",
      ]

      subject = "CN=example.com"
    }
  }
}





