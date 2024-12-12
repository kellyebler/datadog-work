resource "aws_route_table" "kellyebler-route-table" {
    vpc_id = aws_vpc.kellyebler-vpc.id
    route {
        cidr_block = "10.0.0.0/16"
        gateway_id = "local"
    }
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.kellyebler-igw.id
    }
}
