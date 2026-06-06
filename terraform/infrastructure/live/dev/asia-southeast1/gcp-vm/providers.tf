# The provider is the bridge between Terraform and a service.
/*
Terraform code
   |
   v
Google provider
   |
   v
GCP API
   |
   v
Real GCP VM/firewall/network

*/
# Configure Terraform itself.
terraform {
  # Require Terraform CLI version 1.4.0 or newer.
  required_version = ">= 1.4.0"

  # Tell Terraform which provider plugins this project needs.
  required_providers {
    # Use the Google Cloud provider.
    google = {
      # Download the provider from the official HashiCorp namespace.
      source = "hashicorp/google"

      # Allow any Google provider version from 5.0 up to, but not including, 6.0.
      version = "~> 5.0"
    }

    # Used only to write the generated Ansible inventory file on this machine.
    local = {
      source  = "hashicorp/local"
      version = "~> 2.5"
    }

    # Used to create Cloudflare DNS records for service subdomains.
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 5.19"
    }
  }
}

# Configure the Google Cloud provider.
# This is what lets Terraform connect to your GCP account.
provider "google" {
  # GCP project where Terraform will create resources.
  project = var.project_id

  # Default GCP region for regional resources.
  region = var.region

  # If gcp_adc_file is set, load credentials from that ADC JSON file.
  # If gcp_adc_file is empty, use Google's default ADC discovery.
  credentials = var.gcp_adc_file != "" ? file(var.gcp_adc_file) : null
}

# Configure the Cloudflare provider.
# Prefer setting CLOUDFLARE_API_TOKEN in your shell instead of storing the token in terraform.tfvars.
provider "cloudflare" {
  api_token = var.cloudflare_api_token != "" ? var.cloudflare_api_token : null
}
