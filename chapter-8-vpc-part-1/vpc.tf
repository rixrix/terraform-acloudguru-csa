# Setup our aws provider
provider "aws" {
  profile = "${var.aws_profile}"
  region = "${var.vpc_region}"
}

# Define a vpc
resource "aws_vpc" "vpc_name" {
  cidr_block = "${var.vpc_cidr_block}"
  tags {
    Name = "${var.vpc_name}"
    Type = "${var.tag_type}"
    ManagedBy = "${var.tag_managed_by}"
  }
}

# Internet gateway for the public subnet
resource "aws_internet_gateway" "vpc_public_ig" {
  vpc_id = "${aws_vpc.vpc_name.id}"
  tags {
    Name = "vpc_public_ig"
    Type = "${var.tag_type}"
    ManagedBy = "${var.tag_managed_by}"
  }
}

# Public subnet
resource "aws_subnet" "vpc_public_sn" {
  vpc_id = "${aws_vpc.vpc_name.id}"
  cidr_block = "${var.vpc_public_subnet_1_cidr}"
  availability_zone = "${lookup(var.availability_zone, var.vpc_region)}"
  map_public_ip_on_launch = true
  tags {
    Name = "vpc_public_sn"
    Type = "${var.tag_type}"
    ManagedBy = "${var.tag_managed_by}"
  }
}

# Private subnet
resource "aws_subnet" "vpc_private_sn" {
  vpc_id = "${aws_vpc.vpc_name.id}"
  cidr_block = "${var.vpc_private_subnet_1_cidr}"
  availability_zone = "ap-southeast-2b"
  tags {
    Name = "vpc_private_sn"
    Type = "${var.tag_type}"
    ManagedBy = "${var.tag_managed_by}"
  }
}

# Routing table for public subnet
resource "aws_route_table" "vpc_public_sn_rt" {
  vpc_id = "${aws_vpc.vpc_name.id}"
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.vpc_public_ig.id}"
  }
  tags {
    Name = "vpc_public_sn_rt"
    Type = "${var.tag_type}"
    ManagedBy = "${var.tag_managed_by}"
  }
}

# Associate the routing table to public subnet
resource "aws_route_table_association" "vpc_public_sn_rt_assn" {
  subnet_id = "${aws_subnet.vpc_public_sn.id}"
  route_table_id = "${aws_route_table.vpc_public_sn_rt.id}"
}

# ECS Instance Security group
resource "aws_security_group" "vpc_public_sg" {
  name = "vpc_pubic_sg"
  description = "VPC public access security group"
  vpc_id = "${aws_vpc.vpc_name.id}"

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = [
      "${var.vpc_access_from_ip_range}"]
  }

  ingress {
    from_port = 0
    to_port = 0
    protocol = "tcp"
    cidr_blocks = [
      "${var.vpc_public_subnet_1_cidr}"]
  }

  egress {
    # allow all traffic to private SN
    from_port = "0"
    to_port = "0"
    protocol = "-1"
    cidr_blocks = [
      "0.0.0.0/0"]
  }
  tags {
    Name = "vpc_pubic_sg"
    Type = "${var.tag_type}"
    ManagedBy = "${var.tag_managed_by}"
  }
}

resource "aws_security_group" "vpc_private_sg" {
  name = "vpc_private_sg"
  description = "VPC security group to access private ports"
  vpc_id = "${aws_vpc.vpc_name.id}"

  # allow memcached port within VPC
  ingress {
    from_port = 11211
    to_port = 11211
    protocol = "tcp"
    cidr_blocks = [
      "${var.vpc_public_subnet_1_cidr}"]
  }

  # allow redis port within VPC
  ingress {
    from_port = 6379
    to_port = 6379
    protocol = "tcp"
    cidr_blocks = [
      "${var.vpc_public_subnet_1_cidr}"]
  }

  # allow postgres port within VPC
  ingress {
    from_port = 5432
    to_port = 5432
    protocol = "tcp"
    cidr_blocks = [
      "${var.vpc_public_subnet_1_cidr}"]
  }

  # allow mysql port within VPC
  ingress {
    from_port = 3306
    to_port = 3306
    protocol = "tcp"
    cidr_blocks = [
      "${var.vpc_public_subnet_1_cidr}"]
  }

  egress {
    from_port = "0"
    to_port = "0"
    protocol = "-1"
    cidr_blocks = [
      "0.0.0.0/0"]
  }
  tags {
    Name = "vpc_private_sg"
    Type = "${var.tag_type}"
    ManagedBy = "${var.tag_managed_by}"
  }
}

resource "aws_key_pair" "acg_vpc_ch8_kp" {
  key_name = "acg_vpc_ch8_kp"
  public_key = "${file("~/.ssh/id_rsa.pub")}"
}

# Launch EC2 instance
resource "aws_instance" "vpc_public_webserver_ai" {
  ami           = "ami-09b42976632b27e9b"
  instance_type = "t2.micro"
  vpc_security_group_ids = ["${aws_security_group.vpc_public_sg.id}"]
  subnet_id = "${aws_subnet.vpc_public_sn.id}"
  key_name = "acg_vpc_ch8_kp"
  tags {
    Name = "acg_vpc_ch8_ec2"
    Type = "${var.tag_type}"
    ManagedBy = "${var.tag_managed_by}"
  }

  connection {
    user = "ec2-user"
    private_key = "${file("~/.ssh/id_rsa")}"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo yum update -y",
      "sudo yum -y install httpd"
    ]
  }
}

output "vpc_region" {
  value = "${var.vpc_region}"
}

output "vpc_id" {
  value = "${aws_vpc.vpc_name.id}"
}

output "vpc_public_sn_id" {
  value = "${aws_subnet.vpc_public_sn.id}"
}

output "vpc_private_sn_id" {
  value = "${aws_subnet.vpc_private_sn.id}"
}

output "vpc_public_sg_id" {
  value = "${aws_security_group.vpc_public_sg.id}"
}

output "vpc_private_sg_id" {
  value = "${aws_security_group.vpc_private_sg.id}"
}

output "vpc_public_webserver_id" {
  value = "${aws_instance.vpc_public_webserver_ai.id}"
}
