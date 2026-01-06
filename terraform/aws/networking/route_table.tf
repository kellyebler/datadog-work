
resource "aws_route_table" "kellyebler-vpc-rtb-public" {
  vpc_id = aws_vpc.kellyebler-vpc.id
  tags = {
    Name                     = "kellyebler-vpc-rtb-public"
    please_keep_my_resources = "true"
  }
  route {
    cidr_block = "10.0.0.0/16"
    gateway_id = "local"
  }
  # Route to the internet gateway for public access
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.kellyebler-igw.id
  }
}

resource "aws_route_table" "kellyebler-vpc-rtb-private" {
  vpc_id = aws_vpc.kellyebler-vpc.id
  tags = {
    Name                     = "kellyebler-vpc-rtb-private"
    please_keep_my_resources = "true"
  }
  route {
    cidr_block = "10.0.0.0/16"
    gateway_id = "local"
  }
  # Route to NAT Gateway for outbound internet access
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.kellyebler-nat-gw.id
  }
}