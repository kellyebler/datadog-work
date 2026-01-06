# Terraform: aws module

This directory contains two local modules wired together in `main.tf`:

- `module "networking"` (source = `./networking`) — creates the VPC and subnets and exports subnet IDs via outputs (for example `public_subnet_id` and `private_subnet_id`).
- `module "compute"` (source = `./compute`) — creates EC2 resources and receives a subnet ID via an input variable named `public_subnet_id`.

How the subnet ID is passed

- The `networking` module declares outputs in `networking/subnets.tf` such as:

  ```hcl
  output "public_subnet_id" {
    value = aws_subnet.kellyebler-vpc-public-subnet.id
  }
  output "private_subnet_id" {
    value = aws_subnet.kellyebler-vpc-private-subnet.id
  }
  ```

- The root `main.tf` wires that output into the `compute` module by passing the module output as an expression (no quotes):

  ```hcl
  module "networking" {
    source = "./networking"
  }

  module "compute" {
    source = "./compute"
    public_subnet_id = module.networking.public_subnet_id
  }
  ```

- Inside `compute`, `variables.tf` declares `public_subnet_id` and `ec2.tf` uses it:

  ```hcl
  variable "public_subnet_id" { type = string }

  resource "aws_instance" "linux_ec2" {
    # ...
    subnet_id = var.public_subnet_id
    # ...
  }
  ```

Notes / tips

- Modules are separate scopes. You cannot reference `aws_subnet` from `networking` directly inside `compute`; you must pass values through outputs/inputs as shown above.
- If you want the compute module to optionally use the private subnet, pass both outputs to `compute` and add a `use_private_subnet` boolean, or pass the selected subnet id from the root module depending on your environment.