# VPC
resource "aws_vpc" "kellyebler-vpc" {
    cidr_block = "10.0.0.0/16"
}

# Subnets
resource "aws_subnet" "kellyebler-subnet-pub1" {
    vpc_id                  = aws_vpc.kellyebler-vpc.id
    cidr_block              = "10.0.1.0/24"
    availability_zone       = "us-west-2a"
    map_public_ip_on_launch = true
}

resource "aws_subnet" "kellyebler-subnet-pub2" {
    vpc_id                  = aws_vpc.kellyebler-vpc.id
    cidr_block              = "10.0.2.0/24"
    availability_zone       = "us-west-2b"
    map_public_ip_on_launch = true
}

resource "aws_subnet" "kellyebler-subnet-priv3" {
    vpc_id                  = aws_vpc.kellyebler-vpc.id
    cidr_block              = "10.0.3.0/24"
    availability_zone       = "us-west-2a"
    map_public_ip_on_launch = false
}

resource "aws_subnet" "kellyebler-subnet-priv4" {
    vpc_id                  = aws_vpc.kellyebler-vpc.id
    cidr_block              = "10.0.4.0/24"
    availability_zone       = "us-west-2b"
    map_public_ip_on_launch = false
}
