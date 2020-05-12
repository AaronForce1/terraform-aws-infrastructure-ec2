output "ec2_instances" {
  value = aws_instance.ec2_deploy
  description = "exported to use in other module"
}