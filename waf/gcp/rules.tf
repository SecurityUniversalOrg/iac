provider "google" {
  project = "your-project-id"
  region  = "us-central1"
}

resource "google_compute_security_policy" "example" {
  name = "example-security-policy"

  rule {
    action   = "allow"
    priority = 2147483647
    match {
      versioned_expr = "SRC_IPS_V1"
      config {
        src_ip_ranges = ["*"]
      }
    }
    description = "Default rule, higher priority should override"
  }

  rule {
    action   = "deny(403)"
    priority = 1000
    match {
      versioned_expr = "CUSTOM_EXPR"
      config {
        expression = "evaluatePreconfiguredExpr('xss-stable', 'xss-score', 0)"
      }
    }
    description = "OWASP XSS rule"
  }

  rule {
    action   = "deny(403)"
    priority = 2000
    match {
      versioned_expr = "CUSTOM_EXPR"
      config {
        expression = "evaluatePreconfiguredExpr('sqli-stable', 'sqli-score', 0)"
      }
    }
    description = "OWASP SQLi rule"
  }

  rule {
    action   = "deny(403)"
    priority = 3000
    match {
      versioned_expr = "CUSTOM_EXPR"
      config {
        expression = "inIpRange(origin.ip, '192.168.1.0/24')"
      }
    }
    description = "Custom rule to block requests from IP range 192.168.1.0/24"
  }
}
