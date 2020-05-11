terraform {
  required_version = ">= 0.12.6"
}

## APPLICATION VALUES
variable "app_name" {
  description = "Application Name"
}

variable "app_slug" {
  description = "Application Slug"
}

## GLOBAL VAR CONFIGURATION
variable "aws_region" {
  description = "Region for the VPC"
  default = "ap-northeast-2"
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

## AWS REGIONAL VARS
variable "ubuntu_owner" {
  description = "AMI Owner ID for AWS"
  default = "099720109477" # Canonical Singapore
}

## ENVIRONMENT VARS
variable "tfenv" {
  description = "Environment"
}

variable "cidr_block" {
  description = "Default CIDR Blocks to be used to manage VPC internal IP mapping"
  default = "172.42.10.0/23"
}

## ADMINISTRATION VARS
variable "admin_ips" {
  type        = list(string)
  description = "list of ingress ports"
  default     = ["92.40.160.0/19", "202.82.226.146/32"]
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
  default = "yes"
}