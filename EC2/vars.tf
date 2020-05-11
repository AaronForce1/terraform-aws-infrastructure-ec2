
## GLOBAL VAR CONFIGURATION
variable "naming_format" {
  description = "Naming Convention Name within Resources"
}
variable "billingcustomer" {
  description = "Which BILLINGCUSTOMER is setup in AWS"
}
variable "key_name" {
  description = "TF Key"
}
variable "ubuntu_id" {
  description = "AMI Ubuntu ID"
}
variable "aws_region" {
  
}

## APPLICATION VALUES
variable "app_name" {
  description = "Application Name"
}

variable "app_slug" {
  description = "Application Slug"
}


## ENVIRONMENT VARS
variable "tfenv" {
  description = "Environment"
}
variable "vpc_id" {
  description = "VPC ID passed in via module"
}
variable "profile" {
  description = "Environment Profile for deploying EC2 instances"
}
variable "securitygroup" {
  description = "Security Group"
}

## LEGACY VARS
variable "instance_set" {
  description = "Instance Set A or B or X"
}
variable "codebase" {
  description = "tagged tarball of TF code"
}
variable "liveSET" {
  description = "either live or not - set to yes or no"
}
