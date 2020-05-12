output "output_vpc_id" {
  value = aws_vpc.main.id
}

output "output_subnet_ids" {
  value = aws_subnet.main
}