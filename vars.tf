## GLOBAL VALUES
terraform {
  required_version = ">= 0.12.6"
}

variable "profile" {
  description = "Profile of AWS Credential to fetch from ~/.aws/credentials file"
  default = ""
}

variable "serviceaccount_role" {
  description = "Service Account Role expected to run the necessary infrastructure provisioning"
}

## APPLICATION VALUES
variable "app_name" {
  description = "Application Name"
}

variable "app_slug" {
  description = "Application Slug"
}

variable "domain_name" {
  description = "Root domain name for application/EC2 Deployment. By default: hk.asiaticketing.com"
  default = "hk.asiaticketing.com"
}

variable "instance_type" {
  # Standard Types (M | L | XL | XXL): m5.large | c5.xlarge | t3a.2xlarge | m5a.2xlarge
  description = "AWS Instance Type for provisioning"
  default = "m5.large"
}

variable "instance_count" {
  description = "Number of Instances to provision"
  default = "1"
}

variable "internal_ingress_ports" {
  description = "Ports to be opened to allow ingress from Office VPN"
  type = list(string)
  default = []
}

variable "external_ingress_ports" {
  description = "Ports to be opened to allow ingress from the internet"
  type = list(string)
  default = []
}

variable "alb_ingress" {
  description = "ALB Ingress mapping to internal services; Typically the same mapping 1-to-1 of ingress ports above"
  type = list(object({
    internal_port = number
    internal_protocol = string
    external_port = number
  }))
  default = []
}

variable "app_vol_size" {
  description = "Application Volume Size"
    type = list(object({
    vol_size = number
    name = string
  }))
  default = []
}

variable "root_vol_size" {
  description = "Root Volume Size"
  default = "50"
}

## GLOBAL VAR CONFIGURATION
variable "aws_region" {
  description = "Region for the VPC"
  default = "ap-southeast-1"
}

variable "naming_format" {
  description = "Naming Convention Name within Resources"
  default = "ets"
}

variable "billingcustomer" {
  description = "Which BILLINGCUSTOMER is setup in AWS"
  default = "ticketflap"
}

variable "key_name" {
  description = "TF Key"
  default = "ETS-ticketflap-seoul-key"
}

variable "s3_storage" {
  description = "Confirm whether or not to create storage in S3 for application infra"
  type = "list"
  default = []
}

variable "s3_acl" {
  description = "S3 Access Control List: private or public"
  default = "private"
}

variable "rds_instance" {
  description = "Confirm whether or not to create RDS DB storage for application infr"
  default = false
}

## AWS REGIONAL VARS
variable "ubuntu_owner" {
  description = "AMI Owner ID for AWS"
  default = "099720109477" # Canonical Singapore
}

## ENVIRONMENT VARS
variable "tfenv" {
  description = "Environment"
}

variable "ubuntu_version" {
  description = "Ubuntu Version for pulling from AMI and creating EC2"
  default = "20.04"
}

variable "cidr_block" {
  description = "Default CIDR Blocks to be used to manage VPC internal IP mapping"
  default = "172.42.10.0/23"
}

variable "pre_existing_vpc" {
  description = "Define a custom VPC name that this EC2 deployment should attach to, otherwise a custom VPC will be generated for this resource"
  default = false
}

variable "app_name_for_vpc" {
  description = "If you'd like to attach to pre-existing VPC, you need to specify the app name that created the original VPC in order for the system to find it correctly based on {naming_format + tfenv + app_slug}"
  default = "aws-default-vpc"
}

## ADMINISTRATION VARS
variable "admin_ips" {
  type        = list(string)
  description = "list of ingress ports"
  default     = ["202.82.226.146/32"]
}

## LEGACY VARS
variable "instance_set" {
  description = "Instance Set A or B or X"
  default = "X"
}
variable "codebase" {
  description = "tagged tarball of TF code"
  default = "BUILD"
}
variable "liveSET" {
  description = "either live or not - set to yes or no"
  default = "fixed"
}