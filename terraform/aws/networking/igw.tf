resource aws_internet_gateway "kellyebler-igw" {
        vpc_id = aws_vpc.kellyebler-vpc.id
        tags = {
            Name = "kellyebler-vpc-public-subnet-igw"
            please_keep_my_resources = "true"
        }
    }
