resource aws_internet_gateway "kellyebler-igw" {
        vpc_id = aws_vpc.kellyebler-vpc.id
        tags = {
            Name = "kellyebler-igw"
            please_keep_my_resource = "true"
            team = "Enterprise Sales Engineering -- TOLA"
            user = "KellyEbler-EC2"
        }
    }
