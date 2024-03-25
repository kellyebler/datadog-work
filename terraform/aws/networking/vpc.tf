# VPC
resource "aws_vpc" "kellyebler-vpc" {
    cidr_block = "10.0.0.0/16"

    tags = {
        Name                    = "kellyebler-vpc"
        PrincipalId             = "AIDAYYB64AB3O2CKZDRUZ"
        please_keep_my_resource = "true"
        team                    = "Enterprise Sales Engineering -- TOLA"
        user                    = "KellyEbler-EC2"
    }
}

# Subnets
resource "aws_subnet" "kellyebler-subnet-1" {
    vpc_id                  = aws_vpc.kellyebler-vpc.id
    cidr_block              = "10.0.1.0/24"
    availability_zone       = "us-west-2a"
    map_public_ip_on_launch = true

    tags = {
        Name = "kellyebler-subnet-1"
        please_keep_my_resource = "true"
        team = "Enterprise Sales Engineering -- TOLA"
        user = "kelly.ebler@datadoghq.com"
    }
}

resource "aws_subnet" "kellyebler-subnet-2" {
    vpc_id                  = aws_vpc.kellyebler-vpc.id
    cidr_block              = "10.0.2.0/24"
    availability_zone       = "us-west-2b"
    map_public_ip_on_launch = true

    tags = {
        Name = "kellyebler-subnet-2"
        please_keep_my_resource = "true"
        team = "Enterprise Sales Engineering -- TOLA"
        user = "kelly.ebler@datadoghq.com"
    }
}
resource "aws_subnet" "kellyebler-subnet-3" {
    vpc_id                  = aws_vpc.kellyebler-vpc.id
    cidr_block              = "10.0.3.0/24"
    availability_zone       = "us-west-2a"
    map_public_ip_on_launch = false

    tags = {
        Name = "kellyebler-subnet-3"
        please_keep_my_resource = "true"
        team = "Enterprise Sales Engineering -- TOLA"
        user = "kelly.ebler@datadoghq.com"
    }
}

resource "aws_subnet" "kellyebler-subnet-4" {
    vpc_id                  = aws_vpc.kellyebler-vpc.id
    cidr_block              = "10.0.4.0/24"
    availability_zone       = "us-west-2b"
    map_public_ip_on_launch = false

    tags = {
        Name = "kellyebler-subnet-4"
        please_keep_my_resource = "true"
        team = "Enterprise Sales Engineering -- TOLA"
        user = "kelly.ebler@datadoghq.com"
    }
}