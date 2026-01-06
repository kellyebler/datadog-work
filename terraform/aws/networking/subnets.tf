# Public Subnets

resource "aws_subnet" "kellyebler-vpc-public-subnet" {
  vpc_id                  = aws_vpc.kellyebler-vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-west-2a"
  map_public_ip_on_launch = true
  tags = {
    Name                     = "kellyebler-vpc-public-subnet-2a"
    please_keep_my_resources = "true"
  }
}

resource "aws_subnet" "kellyebler-vpc-public-subnet-2b" {
  vpc_id                  = aws_vpc.kellyebler-vpc.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "us-west-2b"
  map_public_ip_on_launch = true
  tags = {
    Name                     = "kellyebler-vpc-public-subnet-2b"
    please_keep_my_resources = "true"
  }
}

output "public_subnet_id" {
  value = aws_subnet.kellyebler-vpc-public-subnet.id
}

output "public_subnet_ids" {
  value = [
    aws_subnet.kellyebler-vpc-public-subnet.id,
    aws_subnet.kellyebler-vpc-public-subnet-2b.id
  ]
}

# Private Subnets

resource "aws_subnet" "kellyebler-vpc-private-subnet" {
  vpc_id                  = aws_vpc.kellyebler-vpc.id
  cidr_block              = "10.0.100.0/24"
  availability_zone       = "us-west-2a"
  map_public_ip_on_launch = false
  tags = {
    Name                     = "kellyebler-vpc-private-subnet-2a"
    please_keep_my_resources = "true"
  }
}

resource "aws_subnet" "kellyebler-vpc-private-subnet-2b" {
  vpc_id                  = aws_vpc.kellyebler-vpc.id
  cidr_block              = "10.0.101.0/24"
  availability_zone       = "us-west-2b"
  map_public_ip_on_launch = false
  tags = {
    Name                     = "kellyebler-vpc-private-subnet-2b"
    please_keep_my_resources = "true"
  }
}

output "private_subnet_id" {
  value = aws_subnet.kellyebler-vpc-private-subnet.id
}

output "private_subnet_ids" {
  value = [
    aws_subnet.kellyebler-vpc-private-subnet.id,
    aws_subnet.kellyebler-vpc-private-subnet-2b.id
  ]
}