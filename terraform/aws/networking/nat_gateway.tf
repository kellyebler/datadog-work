# Elastic IP for NAT Gateway
resource "aws_eip" "nat" {
  domain = "vpc"

  tags = {
    Name                     = "kellyebler-nat-eip"
    please_keep_my_resources = "true"
  }
}

# NAT Gateway
resource "aws_nat_gateway" "kellyebler-nat-gw" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.kellyebler-vpc-public-subnet.id

  tags = {
    Name                     = "kellyebler-nat-gateway"
    please_keep_my_resources = "true"
  }

  depends_on = [aws_internet_gateway.kellyebler-igw]
}
