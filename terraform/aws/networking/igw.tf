resource aws_internet_gateway "kellyebler-igw" {
        vpc_id = aws_vpc.kellyebler-vpc.id
        tags = {
            Name = "kellyebler-igw"
        }
    }
