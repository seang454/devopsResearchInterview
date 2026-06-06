variable "name" {
  description = "Base name for the GCP VM instances. Terraform appends -1, -2, and so on. Use hyphens, not underscores."
  type        = string

  validation {
    condition     = can(regex("^[a-z]([-a-z0-9]*[a-z0-9])?$", var.name))
    error_message = "name must be a valid GCP VM name prefix: lowercase letters, numbers, and hyphens only. It must start with a letter and cannot end with a hyphen."
  }
}

variable "instance_count" {
  description = "Number of VM instances to create."
  type        = number
  default     = 1

  validation {
    condition     = var.instance_count >= 1 && floor(var.instance_count) == var.instance_count
    error_message = "instance_count must be a whole number that is 1 or greater."
  }
}

variable "zone" {
  description = "Fallback GCP zone used when zones is empty."
  type        = string
}

variable "zones" {
  description = "List of GCP zones used to spread VMs. If empty, the module uses zone."
  type        = list(string)
  default     = []

  validation {
    condition     = length(var.zones) == 0 || alltrue([for zone in var.zones : trimspace(zone) != ""])
    error_message = "zones cannot contain empty strings."
  }
}

variable "auto_discover_up_zones" {
  description = "When true, Terraform asks GCP for zones with status UP before building the VM plan."
  type        = bool
  default     = true
}

variable "fallback_regions" {
  description = "Extra GCP regions Terraform may use when preferred zones are down or blocked."
  type        = list(string)
  default     = []

  validation {
    condition     = alltrue([for region in var.fallback_regions : trimspace(region) != ""])
    error_message = "fallback_regions cannot contain empty strings."
  }
}

variable "blocked_zones" {
  description = "GCP zones to skip after a zone is down or exhausted, for example asia-southeast1-a."
  type        = list(string)
  default     = []

  validation {
    condition     = alltrue([for zone in var.blocked_zones : trimspace(zone) != ""])
    error_message = "blocked_zones cannot contain empty strings."
  }
}

variable "blocked_regions" {
  description = "GCP regions to skip after a resource pool is exhausted, for example asia-southeast1."
  type        = list(string)
  default     = []

  validation {
    condition     = alltrue([for region in var.blocked_regions : trimspace(region) != ""])
    error_message = "blocked_regions cannot contain empty strings."
  }
}

variable "machine_types" {
  description = "Machine types by VM index. If there are more VMs than values, Terraform reuses the last value."
  type        = list(string)
  default     = ["e2-standard-2"]

  validation {
    condition     = length(var.machine_types) > 0 && alltrue([for machine_type in var.machine_types : trimspace(machine_type) != ""])
    error_message = "machine_types must contain at least one non-empty machine type."
  }
}

variable "desired_status" {
  description = "Desired VM power state. RUNNING keeps Terraform-managed VMs up; TERMINATED stops them."
  type        = string
  default     = "RUNNING"

  validation {
    condition     = contains(["RUNNING", "TERMINATED"], var.desired_status)
    error_message = "desired_status must be RUNNING or TERMINATED."
  }
}

variable "image" {
  description = "Boot disk image."
  type        = string
  default     = "ubuntu-os-cloud/ubuntu-2404-lts-amd64"
}

variable "boot_disk_size_gb" {
  description = "Boot disk size in GB."
  type        = number
  default     = 30
}

variable "boot_disk_type" {
  description = "Boot disk type."
  type        = string
  default     = "pd-balanced"
}

variable "network" {
  description = "GCP VPC network name or self link."
  type        = string
  default     = "default"
}

variable "subnetwork" {
  description = "GCP subnetwork name or self link. Leave null to use the network default."
  type        = string
  default     = null
}

variable "network_tags" {
  description = "Additional network tags for the VM."
  type        = list(string)
  default     = []
}

variable "ssh_user" {
  description = "Linux SSH username to add to instance metadata."
  type        = string
  default     = "ubuntu"
}

variable "ssh_public_key_path" {
  description = "Path to the SSH public key for VM access."
  type        = string
}

variable "ssh_source_ranges" {
  description = "CIDR ranges allowed to connect to SSH."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "sonarqube_port" {
  description = "SonarQube web port to allow."
  type        = number
  default     = 9000
}

variable "sonarqube_source_ranges" {
  description = "CIDR ranges allowed to access SonarQube."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "http_https_source_ranges" {
  description = "CIDR ranges allowed to access HTTP and HTTPS for Nginx/Certbot."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "labels" {
  description = "GCP labels."
  type        = map(string)
  default     = {}
}
