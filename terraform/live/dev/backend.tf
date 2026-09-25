terraform {

  backend "s3" {

    bucket       = "ai-bankapp-185188589391-terraform-state"
    key          = "dev/terraform.tfstate"
    region       = "ap-south-1"
    use_lockfile = true
    encrypt      = true

  }

}
