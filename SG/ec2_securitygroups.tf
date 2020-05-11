resource "aws_security_group" "ec2_securitygroups" {
  vpc_id       = var.vpc_id
  name         = "${var.naming_format}-${var.tfenv}-${var.app_slug}-sg"
  description  = "ETS ${var.tfenv} security group for ${var.app_name}"

  dynamic "ingress" {
    iterator = ip
    for_each = var.admin_ips
    content {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = [ip.value]
      description = "TF Admin IP address ${ip.key}"
    }
  }
  dynamic "ingress" {
    iterator = ip
    for_each = var.admin_ips
    content {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = [ip.value]
      description = "TF Admin IP address ${ip.key}"
    }
  }

  dynamic "ingress" {
    iterator = ip
    for_each = var.admin_ips
    content {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = [ip.value]
      description = "TF Admin IP address ${ip.key}"
    }
  }

  egress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    description = "all outbound"
  }    
}


output "output_sg" {
  value = aws_security_group.ec2_securitygroups
}