# This block tells Terraform where to store the state file.
terraform {
  # Use the local backend, meaning state is stored on this computer.
  backend "local" {
    # Path to the Terraform state file for dev GCP VM.
    path = "../../../../state/dev/asia-southeast1/gcp-vm.tfstate"
  }
}
