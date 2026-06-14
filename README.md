# GCP Terraform, Ansible, and Kubespray Platform

This interview project provisions GCP infrastructure with Terraform, configures
DevOps services with Ansible, and creates a Kubernetes cluster with Kubespray.
It is designed to run from a Linux control machine.

## Architecture

```mermaid
flowchart LR
  Operator["Linux operator or CI"] --> Terraform
  Terraform --> GCP["GCP VMs, IPs, and firewalls"]
  Terraform --> DNS["Cloudflare DNS"]
  Terraform --> State["Private versioned GCS state"]
  Terraform --> Inventory["Generated Ansible inventories"]
  Inventory --> Ansible
  Ansible --> Services["Jenkins, Nexus, SonarQube, Vault, Trivy, DefectDojo"]
  Inventory --> Kubespray
  Kubespray --> Kubernetes["Kubernetes cluster"]
  User --> DNS --> GCP --> Services
```

## Repository Layout

- `terraform/infrastructure`: service VMs, firewall rules, DNS, and inventories.
- `terraform/k8s_infrastructure`: GCP VMs and inventory for Kubespray.
- `terraform/ansible_service_config`: first-party service configuration roles.
- `terraform/ansible_kubespray_k8s`: Kubespray integration and vendored upstream.
- `.github/workflows/quality.yml`: Terraform, Ansible, and security checks.

## Linux Prerequisites

Install Terraform, Google Cloud CLI, Ansible, `ansible-lint`, and Git. Create an
SSH key and authenticate with GCP:

```bash
ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519
gcloud auth application-default login
```

Update the Terraform examples to use `~/.ssh/id_ed25519.pub` and your trusted
public IP CIDR. Never use `0.0.0.0/0` for SSH or the Kubernetes API.

## First Deployment

Create a private GCS bucket with public access prevention, uniform bucket-level
access, and object versioning. Then prepare local configuration:

```bash
cd terraform/infrastructure/live/dev/asia-southeast1/gcp-vm
cp backend.gcs.hcl.example backend.gcs.hcl
cp terraform.tfvars.example terraform.tfvars
terraform init -backend-config=backend.gcs.hcl
terraform plan
```

Repeat under `terraform/k8s_infrastructure/live/dev/asia-southeast1/kubespray-k8s`
for the Kubernetes stack. Use distinct backend prefixes for every environment.

## Ansible Secrets

Service files reference encrypted vault variables. Create and encrypt each
required local vault file:

```bash
cd terraform/ansible_service_config
cp group_vars/defectdojo/vault.yml.example group_vars/defectdojo/vault.yml
ansible-vault encrypt group_vars/defectdojo/vault.yml
```

Run playbooks with `--ask-vault-pass` or a protected vault-password mechanism.
Rotate the credentials that existed in earlier Git history before real use.

## Environments

Dev, staging, and production examples are provided. Apply non-dev values with a
separate state prefix:

```bash
cp environments/staging.tfvars.example environments/staging.tfvars
terraform plan -var-file=environments/staging.tfvars
cp environments/prod.tfvars.example environments/prod.tfvars
terraform plan -var-file=environments/prod.tfvars
```

Use separate GCP projects and backend prefixes for strong isolation.

## Validation

```bash
bash terraform/infrastructure/scripts/validate-all.sh
bash terraform/k8s_infrastructure/scripts/validate-all.sh
ansible-lint terraform/ansible_service_config/playbooks terraform/ansible_service_config/roles
```

The manual GitHub apply workflow requires a protected `dev` environment and
these repository or environment secrets:

- `GCP_WORKLOAD_IDENTITY_PROVIDER`
- `GCP_SERVICE_ACCOUNT`
- `GCP_STATE_BUCKET`
- `SERVICES_TFVARS_B64`, containing the service stack's base64-encoded `terraform.tfvars`
- `KUBERNETES_TFVARS_B64`, containing the Kubernetes stack's base64-encoded `terraform.tfvars`

Run each Ansible playbook twice. The second run should report no unexpected
changes; keep that output as idempotency evidence for interviews.

After the first successful Terraform initialization, commit the generated
`.terraform.lock.hcl` files so provider selections remain reproducible.

## Interview Evidence

Keep sanitized evidence of a successful CI run, reviewed Terraform plans,
Ansible first-run and idempotent second-run summaries, service health checks,
and Kubernetes node readiness. Do not include IP addresses, credentials, state,
or other access details.

Estimate cost before every deployment with the GCP pricing calculator. The main
cost drivers are six Kubernetes VMs, two service VMs, persistent disks, and
external IPv4 addresses.

## Operations

- Apply service infrastructure: `bash terraform/infrastructure/scripts/apply-dev-and-run-ansible.sh`
- Apply Kubernetes infrastructure: `bash terraform/k8s_infrastructure/scripts/apply-dev-and-run-ansible.sh`
- Recovery guidance: `terraform/infrastructure/docs/disaster-recovery.md`
- Kubespray version policy: `terraform/ansible_kubespray_k8s/KUBESPRAY_DEPENDENCY.md`

Before applying, review the Terraform plan, confirm estimated GCP cost, verify
the backend prefix, and confirm that administrative CIDRs are restricted.
