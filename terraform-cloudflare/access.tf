# Zero Trust Access applications — one per protected subdomain in
# var.access_protected_apps (e.g. admin.example.com, vault.example.com).

resource "cloudflare_zero_trust_access_application" "protected" {
  for_each = var.enable_zero_trust ? toset(var.access_protected_apps) : []

  account_id       = var.account_id
  name             = "${each.value}.${var.domain}"
  domain           = "${each.value}.${var.domain}"
  type             = "self_hosted"
  session_duration = "24h"

  cors_headers = {
    allowed_methods   = ["GET", "POST"]
    allowed_origins    = ["https://${each.value}.${var.domain}"]
    allow_credentials  = true
  }
}
