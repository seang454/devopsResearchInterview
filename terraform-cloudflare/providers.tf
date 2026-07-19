provider "cloudflare" {
  # Set CLOUDFLARE_API_TOKEN as an environment variable instead of hardcoding
  # it here. This var is provided as a fallback for CI systems that inject
  # secrets as -var flags.
  api_token = var.cloudflare_api_token
}
