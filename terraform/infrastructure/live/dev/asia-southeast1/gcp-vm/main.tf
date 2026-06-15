terraform {
  # Supply bucket and prefix from backend.gcs.hcl during terraform init.
  backend "gcs" {}
}
