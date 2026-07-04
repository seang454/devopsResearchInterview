// we will create file name backend.gcs.hcl to store the backend configuration for Terraform state in GCS bucket
//syntax of backend.gcs.hcl will use name of backend.gcs , so it will know which .tf file to generate to main.tf
terraform {
  # Supply bucket and prefix from backend.gcs.hcl during terraform init.
  backend "gcs" {}
}
