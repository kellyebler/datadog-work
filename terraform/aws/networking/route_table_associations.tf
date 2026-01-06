resource "aws_route_table_association" "kellyebler-vpc-rtb-public-association" {
  subnet_id      = aws_subnet.kellyebler-vpc-public-subnet.id
  route_table_id = aws_route_table.kellyebler-vpc-rtb-public.id
}

resource "aws_route_table_association" "kellyebler-vpc-rtb-public-association-2b" {
  subnet_id      = aws_subnet.kellyebler-vpc-public-subnet-2b.id
  route_table_id = aws_route_table.kellyebler-vpc-rtb-public.id
}

resource "aws_route_table_association" "kellyebler-vpc-rtb-private-association" {
  subnet_id      = aws_subnet.kellyebler-vpc-private-subnet.id
  route_table_id = aws_route_table.kellyebler-vpc-rtb-private.id
}

resource "aws_route_table_association" "kellyebler-vpc-rtb-private-association-2b" {
  subnet_id      = aws_subnet.kellyebler-vpc-private-subnet-2b.id
  route_table_id = aws_route_table.kellyebler-vpc-rtb-private.id
}