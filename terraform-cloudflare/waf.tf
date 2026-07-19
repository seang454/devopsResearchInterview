# Cloudflare Managed Ruleset (replaces the legacy WAF Managed Rules UI toggle)
resource "cloudflare_ruleset" "managed_waf" {
  count   = var.waf_managed_rules_enabled ? 1 : 0
  zone_id = var.zone_id
  name    = "Cloudflare Managed WAF"
  kind    = "zone"
  phase   = "http_request_firewall_managed"

  rules = [
    {
      action = "execute"
      action_parameters = {
        id = "efb7b8c949ac4650a09736fc376e9aee" # Cloudflare Managed Ruleset
      }
      expression  = "true"
      description = "Execute Cloudflare Managed Ruleset on all traffic"
      enabled     = true
    },
    {
      action = "execute"
      action_parameters = {
        id = "4814384a9e5d4991b9815dcfc25d2f1f" # OWASP Core Ruleset
        overrides = {
          rules = [
            {
              # Example: relax an OWASP rule that's noisy for your app.
              # Replace with a real rule id you've observed false-positiving.
              id     = "6179ae15870a4bb7b2d480d4843b323c"
              action = "log"
            }
          ]
        }
      }
      expression  = "true"
      description = "Execute OWASP Core Ruleset on all traffic"
      enabled     = true
    }
  ]
}

# Bot Fight Mode / Super Bot Fight Mode
resource "cloudflare_bot_management" "this" {
  zone_id            = var.zone_id
  fight_mode         = true
  enable_js          = true
  using_latest_model = true
}
