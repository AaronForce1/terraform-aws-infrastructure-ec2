
## GLOBAL VAR CONFIGURATION
variable "naming_format" {
  description = "Naming Convention Name within Resources"
}
variable "billingcustomer" {
  description = "Which BILLINGCUSTOMER is setup in AWS"
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
  description = "Name given to the different VPCs"
}

## SG VARS
variable "admin_ips" {
  type        = list(string)
  description = "list of ingress ports"
  default     = ["202.82.226.146/32"]
}