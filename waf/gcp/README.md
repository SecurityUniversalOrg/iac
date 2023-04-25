To deploy a Google Cloud Web Application Firewall (WAF) using Terraform and send logs to an on-premise instance of Splunk, you can configure Google Cloud Armor and Google Cloud Pub/Sub. You'll create a Pub/Sub topic and subscription, export the logs to the Pub/Sub topic, and create a Cloud Function that will be triggered by new logs in the subscription to forward them to your Splunk instance using the HTTP Event Collector (HEC).

This Terraform template configures Google Cloud Platform (GCP) resources for an example web application firewall (WAF) setup. The resources created and configured include:

1. `google provider`: Configures the Google Cloud provider with the project ID and region.
2. `locals`: Defines local variables for the Splunk HEC (HTTP Event Collector) URL and token.
3. `google_compute_network`: Creates a custom Google Compute Network.
4. `google_compute_subnetwork`: Sets up a Google Compute Subnetwork within the custom network with a specific IP range.
5. `google_compute_address`: Reserves a static external IP address.
6. `google_storage_bucket`: Creates a Google Cloud Storage bucket for storing WAF logs and the Cloud Function source code.
7. `google_compute_backend_bucket`: Sets up a backend bucket linked to the Google Storage bucket created earlier.
8. `google_compute_backend_service`: Configures a backend service with Cloud Armor (WAF) enabled.
9. `google_compute_security_policy`: Creates a Cloud Armor security policy.
10. `google_compute_target_http_proxy`: Sets up an HTTP proxy with a URL map.
11. `google_compute_url_map`: Configures a URL map that maps to the backend service.
12. `google_compute_global_forwarding_rule`: Creates a global forwarding rule using the reserved static IP address and the HTTPS proxy.
13. `google_pubsub_topic`: Sets up a Google Pub/Sub topic for WAF logs.
14. `google_pubsub_subscription`: Creates a subscription to the Google Pub/Sub topic.
15. `google_logging_project_sink`: Configures a logging sink to forward logs to the Pub/Sub topic.
16. `google_cloudfunctions_function`: Sets up a Google Cloud Function to process the WAF logs and forward them to a Splunk instance.
17. `google_storage_bucket_object`: Uploads the Cloud Function source code from a local .zip file to the Google Storage bucket.
18. `google_compute_ssl_certificate`: Imports an SSL certificate and private key from local files.
19. `google_compute_target_https_proxy`: Configures an HTTPS proxy with the imported SSL certificate and URL map.

The template sets up a Google Cloud Load Balancer with Cloud Armor (WAF) functionality, which protects the web application from various attacks. It also configures a Google Cloud Function to process WAF logs and forward them to a Splunk instance for analysis and monitoring.
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
