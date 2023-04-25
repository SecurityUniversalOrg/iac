To deploy an Azure Web Application Firewall (WAF) using Terraform and send logs to an on-premise instance of Splunk, you can configure Azure Event Hubs and Azure Functions. The Azure Function will be triggered by new logs in the Event Hub and forward them to your Splunk instance using the HTTP Event Collector (HEC).

This Terraform template configures Azure resources for an example web application firewall (WAF) setup. The resources created and configured include:

1. `azurerm provider`: Configures the Azure provider with default features.
2. `locals`: Defines local variables such as resource group name, location, and Splunk HEC (HTTP Event Collector) URL and token.
3. `azurerm_resource_group`: Creates an Azure resource group with the specified name and location.
4. `azurerm_virtual_network`: Sets up an Azure virtual network with the given name, address space, location, and resource group.
5. `azurerm_subnet`: Creates an Azure subnet within the virtual network and resource group.
6. `azurerm_public_ip`: Allocates a static public IP address with the specified name, location, and resource group.
7. `azurerm_application_gateway`: Configures an Azure application gateway with WAF features, including gateway IP configuration, frontend IP configuration, frontend port, HTTP listener, backend address pool, backend HTTP settings, HTTP route rule, and WAF configuration.
8. `azurerm_eventhub_namespace`: Creates an Azure Event Hubs namespace for event streaming.
9. `azurerm_eventhub`: Sets up an Azure Event Hub within the namespace and resource group.
10. `azurerm_eventhub_namespace_authorization_rule`: Configures an authorization rule for the Event Hubs namespace, granting listen and send permissions.
11. `azurerm_monitor_diagnostic_setting`: Sets up diagnostic settings to forward logs and metrics to the Event Hub.
12. `azurerm_storage_account`: Creates an Azure Storage account for storing WAF logs.
13. `azurerm_function_app`: Sets up an Azure Functions app for processing the WAF logs and forwarding them to Splunk.
14. `azurerm_app_service_plan`: Defines an app service plan for the Azure Functions app.
15. `azurerm_function_app_slot`: Configures a slot for the Azure Functions app.
16. `azurerm_key_vault`: Creates an Azure Key Vault for storing secrets and certificates.
17. `azurerm_key_vault_certificate`: Imports an existing PFX certificate into the Key Vault.

The template sets up an Azure application gateway with WAF functionality, which protects the web application from various attacks. It also configures an Azure Functions app to process WAF logs and forward them to a Splunk instance for analysis and monitoring.
With the provided Terraform configuration, you will create the necessary resources to deploy an Azure Web Application Firewall and send logs to an on-premise instance of Splunk.

After saving the configuration to a file named main.tf, run the following commands:

```sh
terraform init
terraform apply
```

Please note that this configuration doesn't include the actual Azure Function code that is triggered by Event Hubs and forwards logs to Splunk. You will need to create a Python Function App that processes the incoming logs and sends them to your on-premise Splunk instance using the provided SPLUNK_HEC_URL and SPLUNK_HEC_TOKEN.

For more information on creating an Azure Function in Python, refer to the official Azure Functions Python developer guide.

With these steps, you will have successfully configured a Terraform template to deploy an Azure Web Application Firewall and send logs to an on-premise instance of Splunk.
