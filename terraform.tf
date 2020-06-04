locals {
  #array  = [ QTY, NAME, INSTANCE_TYPE, ROLE, SGNAME, VPC_NAME ]
  environments = {
    test  = [ "1", var.app_name, var.instance_type, var.app_slug, join("", [var.app_slug, "-", "sg"])]
    stag  = [ "1", var.app_name, var.instance_type, var.app_slug, join("", [var.app_slug, "-", "sg"])]
    prod  = [ "1", var.app_name, var.instance_type, var.app_slug, join("", [var.app_slug, "-", "sg"])]
  }
}

terraform {
 backend "s3" {}
}

provider "aws" {
  region = var.aws_region
}

############################################

# module "log_bucket" {
#   source                         = "terraform-aws-modules/s3-bucket/aws"
#   version                        = "~> 1.0"

#   bucket                         = "logs-${var.naming_format}-${var.tfenv}-${var.app_slug}"
#   acl                            = "log-delivery-write"
#   force_destroy                  = true
#   attach_elb_log_delivery_policy = true
# }

module "ec2_vpc" {
  source              = "terraform-aws-modules/vpc/aws"
  create_vpc          = !var.pre_existing_vpc

  name                = "${var.naming_format}-${var.tfenv}-${var.app_slug}-vpc"
  cidr                = "172.16.0.0/16"

  azs                 = data.aws_availability_zones.azs.names
  private_subnets     = ["172.16.42.0/24", "172.16.43.0/24"]
  public_subnets      = ["172.16.142.0/24", "172.16.143.0/24"]

  enable_nat_gateway  = true
  enable_vpn_gateway  = true

  tags = {
    Environment       = var.tfenv
  }
}

module "alb_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 3.0"

  name                      = "${var.naming_format}-${var.tfenv}-${var.app_slug}-LB-sg"
  description               = "ETS ${var.tfenv} security group for Load Balancer Supporting: ${var.app_name}"
  vpc_id                    = var.pre_existing_vpc == false ? module.ec2_vpc.vpc_id : data.aws_vpc.env_vpc.id

  ingress_cidr_blocks = ["202.82.226.146/32"]
  ingress_rules       = ["ssh-tcp", "http-80-tcp"]
  egress_rules        = ["all-all"]

  ingress_with_cidr_blocks = [
    for item in var.alb_ingress:
      {
        from_port     = item.external_port
        to_port       = item.external_port
        protocol      = "tcp"
        description   = "Office VPN Access, Load Balancer: ${var.app_name}: ${item.external_port}"
        cidr_blocks   = "202.82.226.146/32"
      }
  ]
}

module "main_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 3.0"

  name                      = "${var.naming_format}-${var.tfenv}-${var.app_slug}-sg"
  description               = "ETS ${var.tfenv} security group for ${var.app_name}"
  vpc_id                    = var.pre_existing_vpc == false ? module.ec2_vpc.vpc_id : data.aws_vpc.env_vpc.id

                        # TODO: Adjust hardcoded gitlab SSH server!
  ingress_cidr_blocks = ["202.82.226.146/32", "172.16.142.0/24", "172.16.143.0/24", "52.76.108.132/32", "52.74.231.214/32"]
  ingress_rules       = ["ssh-tcp"]
  egress_rules        = ["all-all"]

  ingress_with_cidr_blocks = [
    for item in var.alb_ingress:
      {
        from_port     = item.internal_port
        to_port       = item.internal_port
        protocol      = "tcp"
        description   = "Office VPN Access, ${var.app_name}: ${item.internal_port}"
        cidr_blocks   = "202.82.226.146/32"
      }
  ]

  computed_ingress_with_source_security_group_id = [
    for item in var.alb_ingress:
      {
        from_port                 = item.internal_port
        to_port                   = item.internal_port
        protocol                  = "tcp"
        description               = "${module.alb_sg.this_security_group_name}: ${module.alb_sg.this_security_group_description}"
        source_security_group_id  = module.alb_sg.this_security_group_id
      }
  ]
  number_of_computed_ingress_with_source_security_group_id = length(var.alb_ingress)
}

module "ec2" {
  source                        = "terraform-aws-modules/ec2-instance/aws"
  version                       = "2.13.0"

  instance_count                = 1
  name                          = "${var.instance_set}-${var.naming_format}-${var.tfenv}-${var.app_slug}-1-${substr(data.aws_availability_zones.azs.names[0], -1, -1)}"
  
  ami                           = data.aws_ami.ubuntu.id
  instance_type                 = local.environments[var.tfenv][2]
  key_name                      = var.key_name
  monitoring                    = true
  vpc_security_group_ids        = [ "${module.main_sg.this_security_group_id}" ]
  subnet_id                     = tolist(module.ec2_vpc.public_subnets)[0]

  associate_public_ip_address   = true

  tags = {
    ami_used                    = data.aws_ami.ubuntu.id
    autoscale                   = "running"
    billingcustomer             = var.billingcustomer
    build_state                 = "DEPLOYED"
    liveSET                     = var.liveSET
    build_state                 = "provisioned"
    code_base                   = var.codebase
    instance_set                = var.instance_set
    role                        = local.environments[var.tfenv][3]
    tfbasegroup                 = "tfservers"
    tfgroup                     = local.environments[var.tfenv][1]
    tfenv                       = var.tfenv
    tfname                      = "${local.environments[var.tfenv][1]}-${lower(var.instance_set)}"
  }

  root_block_device = [
    {
      volume_type               = "gp2"
      volume_size               = 10
    },
  ]

  ebs_block_device = [
    {
      device_name               = "/dev/xvdb"
      volume_type               = "gp2"
      volume_size               = var.app_vol_size
      encrypted                 = true
    }
  ]

  # user_data_base64 = base64encode("${file("test.sh")}")
}

module "alb" {
  source                        = "terraform-aws-modules/alb/aws"
  version                       = "5.6.0"

  name                          = "LIVE-${var.app_slug}-${var.tfenv}-alb"
  subnets                       = module.ec2_vpc.public_subnets
  security_groups               = [module.alb_sg.this_security_group_id]
  vpc_id                        = module.ec2_vpc.vpc_id
  http_tcp_listeners = [
    {
      port               = 80
      protocol           = "HTTP"
      action_type = "redirect"
      redirect = {
        port        = "443"
        protocol    = "HTTPS"
        status_code = "HTTP_301"
      }
    },
  ]
  https_listeners = [
    for ingress in var.alb_ingress:
      {
        port               = ingress.external_port
        protocol           = "HTTPS"
        certificate_arn    = module.acm.this_acm_certificate_arn
      }
  ]
  target_groups = [
    for ingress in var.alb_ingress:
      {
        name                 = "${var.app_slug}-${var.tfenv}-${ingress.internal_port}-tg"
        backend_protocol     = ingress.internal_protocol
        backend_port         = ingress.internal_port
        target_type          = "instance"
        deregistration_delay = 10
        health_check = {
          enabled             = true
          interval            = 30
          port                = "traffic-port"
          healthy_threshold   = 2
          unhealthy_threshold = 2
          timeout             = 5
          protocol            = ingress.internal_protocol
          matcher             = "200"
        }
      }
  ]
}

resource "aws_route53_record" "dns_record" {
  zone_id = data.aws_route53_zone.this.id
  name    = "${var.app_slug}.${var.tfenv}.${local.domain_name}"
  type    = "A"

  alias {
    name                   = module.alb.this_lb_dns_name
    zone_id                = module.alb.this_lb_zone_id
    evaluate_target_health = true
  }
}

module "nlb" {
  source                        = "terraform-aws-modules/alb/aws"
  version                       = "5.6.0"

  name                          = "LIVE-${var.app_slug}-${var.tfenv}-nlb"
  load_balancer_type            = "network"

  vpc_id                        = module.ec2_vpc.vpc_id
  subnets                       = module.ec2_vpc.public_subnets

  # access_logs = {
  #   bucket = module.log_bucket.this_s3_bucket_id
  # }

  http_tcp_listeners = [
    {
      port                      = 22
      protocol                  = "TCP"
    }
  ]

  target_groups = [
    {
      name                      = "${var.app_slug}-${var.tfenv}-22-tg"
      backend_protocol          = "TCP"
      backend_port              = 22
      target_type               = "instance"
    }
  ]
}

resource "aws_route53_record" "shell_dns_record" {
  zone_id = data.aws_route53_zone.this.id
  name    = "shell.${var.app_slug}.${var.tfenv}.${local.domain_name}"
  type    = "A"

  alias {
    name                   = module.nlb.this_lb_dns_name
    zone_id                = module.nlb.this_lb_zone_id
    evaluate_target_health = true
  }
}

resource "aws_lb_target_group_attachment" "nlb_target_group_attachment" {
  count                         = length(module.nlb.target_group_arns)
  target_group_arn              = module.nlb.target_group_arns[count.index]
  target_id                     = module.ec2.id[0]
}

resource "aws_lb_target_group_attachment" "alb_target_group_attachment" {
  count                         = length(module.alb.target_group_arns)
  target_group_arn              = module.alb.target_group_arns[count.index]
  target_id                     = module.ec2.id[0]
} 

module "acm" {
  source  = "terraform-aws-modules/acm/aws"
  version = "~> 2.0"

  domain_name = "${var.app_slug}.${var.tfenv}.${local.domain_name}" # trimsuffix(data.aws_route53_zone.this.name, ".") # Terraform >= 0.12.17
  zone_id     = data.aws_route53_zone.this.id
}