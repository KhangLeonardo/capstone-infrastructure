variable "resource_name_prefix" {
  description = "Prefix for naming resources"
}

variable "ami" {
  description = "Amazon Machine Image (AMI) ID for the EC2 instance"
  default     = "ami-04f73ca9a4310089f" # Default to Amazon Linux 2 (x86_64)
}

variable "instance_type" {
  description = "Type of EC2 instance"
  default     = "t3.small"
}

variable "public_subnet_ids" {
  description = "ID of the public subnet where the EC2 instance will be launched"
}

variable "vpc_id" {
  description = "ID of the VPC"
}

variable "tags" {
  description = "Optional Tags"
  type        = map(string)
  default     = {}
}

variable "bucket_name" {
  description = "Name of the S3 bucket"
  default     = "jenkins-server-resource"
}

variable "enable_eip" {
  type    = bool
  default = false
}

variable "vpc_s3_endpoint" {
  type = string
}
