provider "google" {
  project = var.project_id
  region  = var.region
}

locals {
  splunk_hec_url  = "https://your-splunk-instance.com:8088/services/collector"
  splunk_hec_token = "your-splunk-hec-token"
}

resource "google_compute_network" "example" {
  name                    = "example-network"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "example" {
  name          = "example-subnetwork"
  ip_cidr_range = "10.0.0.0/24"
  network       = google_compute_network.example.self_link
}

resource "google_compute_address" "example" {
  name = "example-ip"
}

resource "google_compute_backend_bucket" "example" {
  name        = "example-backend-bucket"
  description = "A backend bucket"
  bucket_name = google_storage_bucket.example.name
  enable_cdn  = false
}

resource "google_storage_bucket" "example" {
  name     = "example-waf-logs"
  location = var.region
}

resource "google_compute_backend_service" "example" {
  name        = "example-backend-service"
  description = "A backend service with Cloud Armor enabled"
  protocol    = "HTTP"

  backend {
    group = google_compute_backend_bucket.example.self_link
  }

  security_policy = google_compute_security_policy.example.self_link
}

resource "google_compute_security_policy" "example" {
  name = "example-waf-policy"
}

resource "google_compute_target_http_proxy" "example" {
  name        = "example-http-proxy"
  description = "An HTTP proxy"

  url_map = google_compute_url_map.example.self_link
}

resource "google_compute_url_map" "example" {
  name        = "example-url-map"
  description = "A URL map"

  default_service = google_compute_backend_service.example.self_link
}

resource "google_compute_global_forwarding_rule" "example" {
  name       = "example-global-forwarding-rule"
  ip_address = google_compute_address.example.address
  target     = google_compute_target_https_proxy.example.self_link
  port_range = "443"
}

resource "google_pubsub_topic" "example" {
  name = "example-waf-logs-topic"
}

resource "google_pubsub_subscription" "example" {
  name  = "example-waf-logs-subscription"
  topic = google_pubsub_topic.example.name
}

resource "google_logging_project_sink" "example" {
  name        = "example-waf-logs-sink"
  destination = "pubsub.googleapis.com/projects/${var.project_id}/topics/${google_pubsub_topic.example.name}"

  filter = <<EOF
  resource.type="http_load_balancer_rule"
  log_id("requests")
  EOF
}

resource "google_cloudfunctions_function" "example" {
  name        = "example-waf-logs"
  description = "A Cloud Function to forward logs to Splunk"
  runtime     = "python310"

  available_memory_mb   = 256
  source_archive_bucket = google_storage_bucket.example.name
  source_archive_object = google_storage_bucket_object.example.name
  trigger_http          = false

  event_trigger {
    event_type = "google.pubsub.topic.publish"
    resource   = google_pubsub_topic.example.name
  }

  environment_variables = {
    SPLUNK_HEC_URL  = local.splunk_hec_url
    SPLUNK_HEC_TOKEN = local.splunk_hec_token
  }
}

resource "google_storage_bucket_object" "example" {
  name   = "cloud-function-source.zip"
  bucket = google_storage_bucket.example.name
  source = "path/to/your/cloud-function-source.zip"
}

resource "google_compute_ssl_certificate" "example" {
  name        = "example-ssl-cert"
  private_key = file("<PATH_TO_PRIVATE_KEY>")
  certificate = file("<PATH_TO_CERTIFICATE>")
}

resource "google_compute_target_https_proxy" "example" {
  name             = "example-https-proxy"
  description      = "An HTTPS proxy"
  url_map          = google_compute_url_map.example.self_link
  ssl_certificates = [google_compute_ssl_certificate.example.self_link]
}
