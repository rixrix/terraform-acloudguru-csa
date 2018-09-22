# main creds for AWS connection
variable "aws_profile" {
    description = "AWS profile"
}

variable "tag_type" {
    description = "Resource type tag"
}

variable "tag_managed_by" {
    description = "Resource tag manager"
}

variable "availability_zone" {
  description = "availability zone, based on region"
  default = {
    ap-southeast-2 = "ap-southeast-2a"
  }
}

########################### VPC Config ##################################

variable "vpc_name" {
  description = "VPC for ACloud Guru Chapter-8"
}

variable "vpc_region" {
  description = "AWS region"
}

variable "vpc_cidr_block" {
  description = "Uber IP addressing"
}

variable "vpc_public_subnet_1_cidr" {
  description = "Public 0.0 CIDR for externally accessible subnet"
}

variable "vpc_access_from_ip_range" {
  description = "Access can be made from the following IPs"
}

variable "vpc_private_subnet_1_cidr" {
  description = "Private CIDR for internally accessible subnet"
}
