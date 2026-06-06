param(
    [string]$Playbook = "playbooks/site.yml",
    [string]$Inventory = "inventories/dev/hosts.ini",
    [switch]$SkipCollectionInstall
)

$ErrorActionPreference = "Stop"

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$InfraDir = Resolve-Path (Join-Path $ScriptDir "..\live\dev\asia-southeast1\gcp-vm")
$ProjectDir = Resolve-Path (Join-Path $ScriptDir "..\..")
$AnsibleDir = Join-Path $ProjectDir "ansible_service_config"

Write-Host "Terraform root:"
Write-Host "  $InfraDir"
Write-Host ""

terraform -chdir="$InfraDir" init
terraform -chdir="$InfraDir" apply

Write-Host ""
Write-Host "Terraform completed."

try {
    terraform -chdir="$InfraDir" output ansible_inventory_path
} catch {
    Write-Host "Could not read ansible_inventory_path output."
}

try {
    terraform -chdir="$InfraDir" output cloudflare_hostnames
} catch {
    Write-Host "Could not read cloudflare_hostnames output."
}

Write-Host ""
$Answer = Read-Host "Run Ansible now with $Playbook? [y/N]"

if ($Answer -notmatch "^(y|yes)$") {
    Write-Host "Stopped after Terraform. Ansible was not run."
    exit 0
}

if (-not (Get-Command ansible-playbook -ErrorAction SilentlyContinue)) {
    Write-Error "ansible-playbook was not found. Run this script where Ansible is installed, for example WSL/Linux."
}

Push-Location $AnsibleDir
try {
    if (-not $SkipCollectionInstall -and (Get-Command ansible-galaxy -ErrorAction SilentlyContinue)) {
        ansible-galaxy collection install -r collections/requirements.yml
    }

    ansible-playbook -i $Inventory $Playbook
} finally {
    Pop-Location
}
