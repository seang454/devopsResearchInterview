/*
This live dev root module calls the reusable GCP VM module.

Flow:
live/dev/asia-southeast1/gcp-vm/gcp_vm.tf
  -> modules/gcp-vm
  -> creates GCP VM instances and firewall rules

gcp_vm.tf in live/dev
        |
        | calls
        v
modules/gcp-vm
        |
        | creates
        v
GCP VM instances + firewall rules

*/

module "gcp_vm" {
  source = "../../../../modules/gcp-vm"

  name                   = var.name
  instance_count         = var.instance_count
  zone                   = var.zone
  zones                  = var.zones
  auto_discover_up_zones = var.auto_discover_up_zones
  fallback_regions       = var.fallback_regions
  blocked_zones          = var.blocked_zones
  blocked_regions        = var.blocked_regions
  machine_types          = var.machine_types
  desired_status         = var.desired_status
  image                  = var.image
  boot_disk_size_gb      = var.boot_disk_size_gb
  boot_disk_type         = var.boot_disk_type
  network                = var.network
  subnetwork             = var.subnetwork
  ssh_user               = var.ssh_user
  ssh_public_key_path    = var.ssh_public_key_path

  ssh_source_ranges        = var.ssh_source_ranges
  sonarqube_port           = var.sonarqube_port
  sonarqube_source_ranges  = var.sonarqube_source_ranges
  http_https_source_ranges = var.http_https_source_ranges

  labels = {
    environment = "dev"
    app         = "sonarqube"
    managed_by  = "terraform"
  }
}
