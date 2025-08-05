# VPC
resource "aws_vpc" "kellyebler-vpc" {
    cidr_block = "10.0.0.0/16"
    tags = {
      Name = "kellyebler-vpc"
      please_keep_my_resources = "true"
    }
}