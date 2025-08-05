# Public Subnet

resource "aws_subnet" "kellyebler-vpc-public-subnet" {
    vpc_id                  = aws_vpc.kellyebler-vpc.id
    cidr_block              = "10.0.1.0/24"
    availability_zone       = "us-west-2a"
    map_public_ip_on_launch = true
    tags = {
      Name = "kellyebler-vpc-public-subnet"
      please_keep_my_resources = "true"
    }
}

# Private Subnet

resource "aws_subnet" "kellyebler-vpc-private-subnet" {
    vpc_id                  = aws_vpc.kellyebler-vpc.id
    cidr_block              = "10.0.100.0/24"
    availability_zone       = "us-west-2a"
    map_public_ip_on_launch = false
    tags = {
      Name = "kellyebler-vpc-private-subnet"
      please_keep_my_resources = "true"
    }
}