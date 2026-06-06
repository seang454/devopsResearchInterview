# GCP VM Module

This module creates one or more Google Compute Engine VMs for SonarQube and opens firewall access for:

- SSH port `22`
- SonarQube web port `9000`
- HTTP port `80` and HTTPS port `443` for Nginx and Certbot

Terraform creates the VM. Ansible configures the software on the VM.

For HTTPS with Certbot, keep `http_https_source_ranges` open to the public internet unless you use a different certificate validation method:

```hcl
http_https_source_ranges = ["0.0.0.0/0"]
```

## Dynamic VM Count

Use `instance_count` to choose how many VMs Terraform creates.

```hcl
instance_count = 3
```

The module names the machines from the base `name`:

```text
gcp-vm-1
gcp-vm-2
gcp-vm-3
```

## Dynamic Zones

Use `zones` to spread machines across multiple GCP zones.

```hcl
zones = [
  "asia-southeast1-a",
  "asia-southeast1-b",
  "asia-southeast1-c"
]
```

Terraform assigns zones in order:

```text
gcp-vm-1 -> asia-southeast1-a
gcp-vm-2 -> asia-southeast1-b
gcp-vm-3 -> asia-southeast1-c
gcp-vm-4 -> asia-southeast1-a
```

If `zones = []`, the module uses the single `zone` value.

## Dynamic UP Zone Discovery

When `auto_discover_up_zones = true`, Terraform asks GCP for zones with status `UP` before creating the VM plan.

```hcl
auto_discover_up_zones = true

fallback_regions = [
  "asia-east1",
  "asia-northeast1"
]
```

Terraform uses zones in this order:

```text
1. Preferred zones from zones, but only if GCP reports them as UP
2. Other UP zones in the same regions
3. UP zones from fallback_regions
```

## Block Failed Zones Or Regions

Terraform cannot catch a GCP create error and retry another zone inside the same `terraform apply`. Instead, mark failed locations as blocked and rerun Terraform.

```hcl
blocked_zones = [
  "asia-southeast1-a"
]

blocked_regions = [
  "asia-southeast1"
]
```

The module removes blocked zones and blocked regions from the configured `zones` list before building the machine plan.

## Keep VMs Running

Use `desired_status` to tell Terraform the expected VM power state.

```hcl
desired_status = "RUNNING"
```

This is the Terraform version of starting a stopped VM, but only for VMs already managed in Terraform state.

## Dynamic Machine Types

Use `machine_types` to choose the VM size by index.

```hcl
instance_count = 3

machine_types = [
  "e2-standard-2", # gcp-vm-1
  "e2-standard-4", # gcp-vm-2
  "e2-medium"      # gcp-vm-3 and later VMs
]
```

Terraform matches the VM to the list by index:

```text
VM 1 -> machine_types[0]
VM 2 -> machine_types[1]
VM 3 -> machine_types[2]
```

If there are more VMs than `machine_types` values, Terraform reuses the last value.

```text
1 machine type  -> all VMs use machine_types[0]
2 machine types -> VM 1 uses machine_types[0], VM 2 and later use machine_types[1]
3 machine types -> VM 1 uses machine_types[0], VM 2 uses machine_types[1], VM 3 and later use machine_types[2]
```

## Outputs

For one VM, you can still use:

```hcl
server_ip
```

For many VMs, use:

```hcl
machine_plan
discovery_regions
discovered_up_zones
candidate_zones
server_ips
static_ips
instances
sonarqube_urls
```

Use the IP addresses in Ansible inventory:

```text
[sonarqube]
SERVER_IP_1 ansible_user=ubuntu ansible_ssh_private_key_file=~/.ssh/id_rsa
SERVER_IP_2 ansible_user=ubuntu ansible_ssh_private_key_file=~/.ssh/id_rsa
```
