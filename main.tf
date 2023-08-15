# Terraformの設定
terraform {
  required_version = "~>1.5.5"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# AWS Providerの設定
provider "aws" {
  region = "ap-northeast-1"
}

# VPC作成
resource "aws_vpc" "sample" {
  cidr_block = "10.0.0.0/16"
  tags = {
    "Name" = "sample-vpc"
  }
}

# インターネットゲートウェイ
resource "aws_internet_gateway" "sample" {
  vpc_id = aws_vpc.sample.id
  tags = {
    "Name" = "sample-igw"
  }
}

# パブリックサブネット
resource "aws_subnet" "public" {
  vpc_id = aws_vpc.sample.id
  availability_zone = "ap-northeast-1a"
  cidr_block = "10.0.1.0/24"
  map_public_ip_on_launch = true
  tags = {
    "Name" = "sample-public-subnet"
  }
}

# ルートテーブル
resource "aws_route_table" "sample_route_table" {
  vpc_id = aws_vpc.sample.id
}

# インターネットに向けるルート
resource "aws_route" "route_to_igw" {
  route_table_id = aws_route_table.sample_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.sample.id
  depends_on = [ aws_route_table.sample_route_table ]
}

# ルートテーブルとパブリックサブネットの紐付け
resource "aws_route_table_association" "with_public_subnet" {
  subnet_id = aws_subnet.public.id
  route_table_id = aws_route_table.sample_route_table.id
}

# セキュリティグループ
resource "aws_security_group" "sample" {
  name = "allow-http"
  vpc_id = aws_vpc.sample.id
}

# セキュリティグループ(HTTP)
resource "aws_security_group_rule" "allow_http_from_anywhere" {
  type = "ingress"
  protocol = "tcp"
  from_port = 80
  to_port = 80
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = aws_security_group.sample.id
}

# セキュリティグループ(SSH)
resource "aws_security_group_rule" "allow_ssh_from_anywhere" {
  type = "ingress"
  protocol = "tcp"
  from_port = 22
  to_port = 22
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = aws_security_group.sample.id
}

# セキュリティグループ(HTTPS)
resource "aws_security_group_rule" "allow_https_from_anywhere" {
  type = "ingress"
  protocol = "tcp"
  from_port = 443
  to_port = 443
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = aws_security_group.sample.id
}

# セキュリティグループ(-1)
resource "aws_security_group_rule" "allow_all_to_anywhere" {
  type = "egress"
  protocol = "-1"
  from_port = 0
  to_port = 0
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = aws_security_group.sample.id
}

# EC2インスタンス
resource "aws_instance" "sample" {
  # Ubuntu 22.04.LTS
  ami = "ami-088da9557aae42f39"
  # インスタンスタイプ
  instance_type = "t3.micro"
  subnet_id = aws_subnet.public.id
  vpc_security_group_ids = [ aws_security_group.sample.id ]

  user_data = <<EOF
    apt update -y
  EOF 
}