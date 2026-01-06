variable "public_subnet_id" {
  description = "The ID of the public subnet to launch the EC2 instance into"
  type        = string
}

variable "private_subnet_id" {
  description = "The ID of the private subnet for EKS nodes"
  type        = string
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs for EKS cluster"
  type        = list(string)
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs for EKS nodes"
  type        = list(string)
}
