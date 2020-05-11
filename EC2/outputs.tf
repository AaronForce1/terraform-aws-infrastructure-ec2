output "subnet_list" {
  value = local.subnet_ids_list
  description = "exported to use in other module"
}

output "ec2_instances" {
  value = aws_instance.ec2_deploy
  description = "exported to use in other module"
}