# used as a hack to join the subnets listed into an array
locals {                                                            
  subnet_ids_string = join(",", data.aws_subnet_ids.vpc_subnets.ids)
  subnet_ids_list = split(",", local.subnet_ids_string)        
}