data "aws_vpc" "env_vpc" {
    filter {
        name   = "tag:Name"
        values = var.pre_existing_vpc ? ["${var.naming_format}-${var.tfenv}-${var.app_name_for_vpc}-vpc"] : ["flap-internal-vpc"]
    }
}

data "aws_subnet_ids" "env_vpc_public_subnets" {
  vpc_id = data.aws_vpc.env_vpc.id
  
  filter {
    name = "tag:Name"
    values = var.pre_existing_vpc ? ["*-public-*"] : ["*-external-*"]
  }
}

data "aws_subnet_ids" "env_vpc_private_subnets" {
  vpc_id = data.aws_vpc.env_vpc.id
  
  filter {
    name = "tag:Name"
    values = var.pre_existing_vpc ? ["*-private-*"] : ["*-internal-*"]
  }
}

data "aws_ami" "ubuntu" {
    most_recent = true

    filter {
        name   = "name"
        values = ["ubuntu/images/hvm-ssd/ubuntu-*${var.ubuntu_version}-amd64-server-*"]
    }

    filter {
        name   = "virtualization-type"
        values = ["hvm"]
    }

    owners = [ var.ubuntu_owner ] #Canonical
}

# These datasource lookups pull back a LIST of results, even if there is only one result. This has to be taken care of in your module - e.g. ids[0]
data "aws_security_groups" "fd-admin-protocols" {
  filter {
    name   = "group-name"
    values = ["fd-admin-protocols-sg"]
  }
}

data "aws_security_groups" "env_sg" {
  filter {
    name  = "tag:Name"
    values = var.pre_existing_vpc ? ["${var.naming_format}-${var.tfenv}-${var.app_name_for_vpc}-sg"] : ["fd-admin-protocols-sg"]
  }
}

data "aws_security_groups" "alb_sg" {
  filter {
    name = "tag:Name"
    values = var.pre_existing_vpc ? ["${var.naming_format}-${var.tfenv}-${var.app_name_for_vpc}-LB-sg"] : ["fd-admin-protocols-sg"]
  }
}

data "aws_availability_zones" "azs" {
}

data "aws_route53_zone" "this" {
  name = local.domain_name
}
