param(
    [string]$Playbook = "cluster.yml",
    [string]$Inventory = "inventory/sample/inventory.ini",
    [switch]$SkipRequirementsInstall
)

$ErrorActionPreference = "Stop"

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$InfraDir = Resolve-Path (Join-Path $ScriptDir "..\live\dev\asia-southeast1\kubespray-k8s")
$ProjectDir = Resolve-Path (Join-Path $ScriptDir "..\..")
$KubesprayDir = Join-Path $ProjectDir "ansible_kubespray_k8s\kubespray"

Write-Host "Terraform root:"
Write-Host "  $InfraDir"
Write-Host ""

terraform -chdir="$InfraDir" init
terraform -chdir="$InfraDir" apply

Write-Host ""
Write-Host "Terraform completed."

try {
    terraform -chdir="$InfraDir" output kubespray_inventory_path
} catch {
    Write-Host "Could not read kubespray_inventory_path output."
}

Write-Host ""
$Answer = Read-Host "Run Kubespray now with $Playbook? [y/N]"

if ($Answer -notmatch "^(y|yes)$") {
    Write-Host "Stopped after Terraform. Kubespray was not run."
    exit 0
}

if (-not (Get-Command ansible-playbook -ErrorAction SilentlyContinue)) {
    Write-Error "ansible-playbook was not found. Run this script where Ansible is installed, for example WSL/Linux."
}

Push-Location $KubesprayDir
try {
    if (-not $SkipRequirementsInstall -and (Test-Path "requirements.txt") -and (Get-Command pip3 -ErrorAction SilentlyContinue)) {
        pip3 install -r requirements.txt
    }

    ansible-playbook -i $Inventory $Playbook
} finally {
    Pop-Location
}
