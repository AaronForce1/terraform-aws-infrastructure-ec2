locals {
  #array  = [ QTY, NAME, INSTANCE_TYPE, ROLE, SGNAME ]
  environments = {
    test  = [ "1", var.app_name, "m5.large", var.app_slug,  join("", [var.app_slug, "-", "sg"])]
    stag  = [ "1", var.app_name, "c5.xlarge", var.app_slug, join("", [var.app_slug, "-", "sg"])]
    prod  = [ "1", var.app_name, "c5.xlarge", var.app_slug, join("", [var.app_slug, "-", "sg"])]
  }
}

terraform {
 backend "s3" {}
}

provider "aws" {
  region = var.aws_region
}

############################################

module "ec2_vpc" {
  source        = "./VPC"
  tfenv         = var.tfenv
  subcount      = 2
  cidr_block    = "172.16.42.0/23"
  subnets_cidr  = ["172.16.42.0/24", "172.16.43.0/24"]
  naming_format = var.naming_format
  app_slug      = var.app_slug
}

module "ec2_securitygroups" {
  source = "./SG"
  app_name                  = var.app_name
  app_slug                  = var.app_slug
  tfenv                     = var.tfenv
  vpc_id                    = module.ec2_vpc.output_vpc_id
  billingcustomer           = var.billingcustomer
  naming_format             = var.naming_format
}

module "ec2_deploy" {
  source                    = "./EC2"
  app_name                  = var.app_name
  app_slug                  = var.app_slug
  instance_set              = var.instance_set
  codebase                  = var.codebase
  tfenv                     = var.tfenv
  vpc_id                    = module.ec2_vpc.output_vpc_id
  vpc_subnet_ids            = module.ec2_vpc.output_subnet_ids
  securitygroup             = module.ec2_securitygroups.output_sgs
  naming_format             = var.naming_format
  key_name                  = var.key_name
  profile                   = local.environments[var.tfenv]
  liveSET                   = var.liveSET
  ubuntu_id                 = data.aws_ami.ubuntu.id
  billingcustomer           = var.billingcustomer
  aws_region                = var.aws_region
}