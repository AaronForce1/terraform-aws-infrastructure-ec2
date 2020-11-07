output "ec2_instances" {
  value = module.ec2
}

output "output_sgs" {
  value = module.main_sg
}

output "rds_password" {
  value = var.rds_instance ? random_password.rds_password.result : ""
}

output "ec2_vpc" {
  value = module.ec2_vpc
}