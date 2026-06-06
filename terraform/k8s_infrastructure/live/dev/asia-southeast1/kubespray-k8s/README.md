# Dev Kubespray GCP Infrastructure

This Terraform root creates GCP VMs for a Kubespray Kubernetes cluster and writes the real VM IPs into the Kubespray inventory.

Terraform creates:

- Control plane VMs, for example `master01`, `master02`, `master03`.
- Worker VMs, for example `worker01`, `worker02`, `worker03`.
- Static external IPs for SSH.
- Internal IPs used by Kubespray as `ip=...`.
- Firewall rules for SSH, internal cluster traffic, and Kubernetes API access.
- The generated Kubespray inventory file.

Terraform does not run Kubespray. After `terraform apply`, run Kubespray with Ansible.

## Configure Node Counts

Use `terraform.tfvars`:

```hcl
control_plane_count = 3
worker_count        = 3
```

For stacked etcd, `1` or `3` control plane nodes is usually better than `2`.

## Generated Inventory

Terraform writes:

```text
terraform/ansible_kubespray_k8s/kubespray/inventory/sample/inventory.ini
```

The inventory format lives in:

```text
templates/kubespray_inventory.tftpl
```

Terraform renders it with `templatefile()` and then writes the result with the `local_file` resource.

Example generated inventory:

```ini
[kube_control_plane]
master01 ansible_host=<master01-public-ip> ip=<master01-private-ip> etcd_member_name=master01
master02 ansible_host=<master02-public-ip> ip=<master02-private-ip> etcd_member_name=master02

[etcd:children]
kube_control_plane

[kube_node]
worker01 ansible_host=<worker01-public-ip> ip=<worker01-private-ip>

[k8s_cluster:children]
kube_control_plane
kube_node
```

`ansible_host` is the external IP Ansible uses for SSH.

`ip` is the internal GCP IP Kubernetes nodes use to talk to each other.

## Run Terraform

```bash
cd terraform/k8s_infrastructure/live/dev/asia-southeast1/kubespray-k8s
terraform init
terraform plan
terraform apply
terraform output kubespray_inventory_path
terraform output control_plane_nodes
terraform output worker_nodes
```

## Run Kubespray

After Terraform finishes:

```bash
cd terraform/ansible_kubespray_k8s/kubespray
ansible-playbook -i inventory/sample/inventory.ini cluster.yml
```

## Important Variables

```hcl
control_plane_count = 3
worker_count        = 3

ssh_user            = "seang"
ssh_public_key_path = "/home/seang/.ssh/id_rsa.pub"

ansible_user                 = "seang"
ansible_ssh_private_key_file = "/home/seang/.ssh/id_rsa"

kubespray_inventory_path = "../../../../../ansible_kubespray_k8s/kubespray/inventory/sample/inventory.ini"
```

## What Was Removed

This Kubernetes infra does not use:

- Cloudflare DNS records.
- SonarQube/Jenkins/Nexus/DefectDojo/Trivy/Vault service inventory.
- Terraform-generated Ansible service `group_vars`.

Those belong to `terraform/infrastructure`, not `terraform/k8s_infrastructure`.
