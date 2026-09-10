terraform {
  backend "s3" {
    bucket       = "ai-bankapp-595231957348-terraform-state"
    key          = "uat/terraform.tfstate"
    region       = "ap-south-1"
    use_lockfile = true
    encrypt      = true
  }
}
