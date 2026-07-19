# Rate limiting on sensitive paths (login, API, wp-login.php, etc.)
# driven by var.rate_limited_paths.

resource "cloudflare_ruleset" "rate_limiting" {
  zone_id = var.zone_id
  name    = "Rate limiting rules"
  kind    = "zone"
  phase   = "http_ratelimit"

  rules = [
    for key, rl in var.rate_limited_paths : {
      action      = "block"
      expression  = "http.request.uri.path matches \"${rl.path}\""
      description = "Rate limit ${key}: ${rl.requests_per_period} req / ${rl.period_seconds}s"
      enabled     = true
      action_parameters = {
        response = {
          status_code  = 429
          content      = "{\"error\":\"rate limited, try again later\"}"
          content_type = "application/json"
        }
      }
      ratelimit = {
        characteristics     = ["ip.src", "cf.colo.id"]
        period              = rl.period_seconds
        requests_per_period = rl.requests_per_period
        mitigation_timeout  = rl.mitigation_timeout
      }
    }
  ]
}
