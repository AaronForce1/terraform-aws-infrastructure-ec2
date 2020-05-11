# VPC
resource "aws_vpc" "main" {
  cidr_block       = var.cidr_block
  enable_dns_hostnames = true

  tags = {
    Environment = var.tfenv
    Name = "${var.naming_format}-${var.tfenv}-vpc"
  }
}

# Subnet
resource "aws_subnet" "main" {
  count = var.subcount
  vpc_id = aws_vpc.main.id
  cidr_block = "${element(var.subnets_cidr,count.index)}"
  availability_zone = "${element(data.aws_availability_zones.azs.names,count.index)}"

  tags = {
    Environment = var.tfenv
    Name = "${var.naming_format}-${var.tfenv}-${element(data.aws_availability_zones.azs.names,count.index)}"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Environment = var.tfenv
    Name = "${var.naming_format}-${var.tfenv}-igw"
  }
}

# Route table: attach Internet Gateway 
resource "aws_route_table" "main" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.main.id}"
  }
  tags = {
    Environment = var.tfenv
    Name = "${var.naming_format}-${var.tfenv}-rt"
  }
}

resource "aws_route_table_association" "main" {
  count = var.subcount
  subnet_id      = aws_subnet.main[count.index].id
  route_table_id = aws_route_table.main.id
}

