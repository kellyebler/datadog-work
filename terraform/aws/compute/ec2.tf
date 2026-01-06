resource "aws_instance" "linux_ec2" {
  ami           = "ami-05f991c49d264708f" # Ubuntu Server 22.04 LTS (us-west-2)
  instance_type = "m5.2xlarge"
  subnet_id     = var.public_subnet_id
  key_name      = "kelly"

  tags = {
    Name                    = "kellyebler-ubuntu-ec2"
    please_keep_my_resource = "true"
  }
}