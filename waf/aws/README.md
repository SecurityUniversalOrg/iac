This Terraform configuration creates the necessary resources to deploy an AWS Web Application Firewall (WAF) and sends the WAF logs to an on-premise instance of Splunk. Be sure to replace the placeholders in the locals block with your actual Splunk instance URL, HEC token, and desired port.

After saving the configuration to a file named main.tf, run the following commands:

```sh
terraform init
terraform apply
```

Once the resources are created, you need to configure your AWS WAF to send logs to the Kinesis Data Firehose delivery stream. Follow the instructions in the official AWS documentation to set up WAF logging for the newly created Web ACL.

Finally, make sure your on-premise Splunk instance is configured to receive data from AWS Kinesis Data Firehose. For more details, refer to the official Splunk documentation.

With these steps, you will have successfully configured a Terraform template to deploy an AWS Web Application Firewall and send logs to an on-premise instance of Splunk.