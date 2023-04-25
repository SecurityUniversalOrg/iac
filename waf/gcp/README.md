To deploy a Google Cloud Web Application Firewall (WAF) using Terraform and send logs to an on-premise instance of Splunk, you can configure Google Cloud Armor and Google Cloud Pub/Sub. You'll create a Pub/Sub topic and subscription, export the logs to the Pub/Sub topic, and create a Cloud Function that will be triggered by new logs in the subscription to forward them to your Splunk instance using the HTTP Event Collector (HEC).

Save the following code to a file named main.tf. This Terraform configuration creates the necessary resources:

1. A network, subnetwork, and an external IP address
2. A target HTTP proxy and global forwarding rule
3. A backend bucket and backend service with Cloud Armor enabled
4. A Pub/Sub topic and subscription
5. A Cloud Function with a Pub/Sub trigger

After saving the configuration to a file named `main.tf`, create a `variables.tf` file to define the necessary variables:
```hcl
variable "project_id" {
  description = "The project ID"
  type        = string
}

variable "region" {
  description = "The region"
  type        = string
  default     = "us-central1"
}
```

Create a `terraform.tfvars` file to provide values for the variables:
```hcl
project_id = "your-project-id"
region     = "your-region"
```

Please note that this configuration doesn't include the actual Cloud Function code that is triggered by Pub/Sub and forwards logs to Splunk. You will need to create a Python Cloud Function that processes the incoming logs and sends them to your on-premise Splunk instance using the provided `SPLUNK_HEC_URL` and `SPLUNK_HEC_TOKEN`. You should create a `cloud-function-source.zip` archive containing your Cloud Function code and update the `source` attribute in the `google_storage_bucket_object` resource accordingly.

With these steps, you will have successfully configured a Terraform template to deploy a Google Cloud Web Application Firewall and send logs to an on-premise instance of Splunk.
