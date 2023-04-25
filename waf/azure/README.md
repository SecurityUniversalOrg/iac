To deploy an Azure Web Application Firewall (WAF) using Terraform and send logs to an on-premise instance of Splunk, you can configure Azure Event Hubs and Azure Functions. The Azure Function will be triggered by new logs in the Event Hub and forward them to your Splunk instance using the HTTP Event Collector (HEC).

Save the following code to a file named main.tf. This Terraform configuration creates the necessary resources:

1. A resource group, virtual network, and subnet
2. A public IP and application gateway with WAF enabled
3. An Event Hubs Namespace, Event Hub, and Diagnostic settings for the Application Gateway
4. A Storage Account and an Azure Functions App
5. An Azure Function with an Event Hub trigger

With the provided Terraform configuration, you will create the necessary resources to deploy an Azure Web Application Firewall and send logs to an on-premise instance of Splunk.

After saving the configuration to a file named main.tf, run the following commands:

```sh
terraform init
terraform apply
```

Please note that this configuration doesn't include the actual Azure Function code that is triggered by Event Hubs and forwards logs to Splunk. You will need to create a Python Function App that processes the incoming logs and sends them to your on-premise Splunk instance using the provided SPLUNK_HEC_URL and SPLUNK_HEC_TOKEN.

For more information on creating an Azure Function in Python, refer to the official Azure Functions Python developer guide.

With these steps, you will have successfully configured a Terraform template to deploy an Azure Web Application Firewall and send logs to an on-premise instance of Splunk.
