# main.tf

terraform {
  cloud {
    organization = "kellyebler183451b6"
    workspaces {
      name = "datadog-work"
    }
  }
}

# Configure the AWS provider
provider "aws" {
  region     = "us-west-2" # Replace with your desired region
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}


module "networking" {
  source = "./networking"
}

module "compute" {
  source             = "./compute"
  public_subnet_id   = module.networking.public_subnet_id
  private_subnet_id  = module.networking.private_subnet_id
  public_subnet_ids  = module.networking.public_subnet_ids
  private_subnet_ids = module.networking.private_subnet_ids
}