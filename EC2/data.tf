# These datasource lookups pull back a LIST of results, even if there is only one result. This has to be taken care of in your module - e.g. ids[0]
data "aws_security_groups" "vpc_security_groups" {
  filter {
    name   = "vpc-id"
    values = [ var.vpc_id ]
  }
}

data "aws_availability_zones" "azs" {
}