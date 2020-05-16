resource "aws_instance" "ec2_deploy" {
    ami                             = var.ubuntu_id
    instance_type                   = var.profile[2]
    key_name                        = var.key_name
    subnet_id                       = element(var.vpc_subnet_ids, count.index).id
    associate_public_ip_address     = true #tfsec:ignore:AWS012
    # security groups which already exists return ids and an array - SG's which are being built by terraform simply have an id
    vpc_security_group_ids          = data.aws_security_groups.vpc_security_groups.ids
    count                           = var.profile[0]
    tags = {
        Name = "${var.instance_set}-${var.naming_format}-${var.tfenv}-${var.profile[1]}-${ ceil(((count.index - ((ceil(count.index % 2) )) + 2) / 2)) }-${substr(data.aws_availability_zones.azs.names[count.index % 2], -1, -1)}"
        ami_used = var.ubuntu_id
        autoscale = "running"
        billingcustomer = var.billingcustomer
        build_state = "DEPLOYED"
        liveSET = var.liveSET
        build_state = "provisioned"
        code_base = var.codebase
        instance_set = var.instance_set
        role = var.profile[3]
        tfbasegroup = "tfservers"
        tfgroup = var.profile[1]
        tfenv = var.tfenv
        tfname = "${var.profile[1]}-${lower(var.instance_set)}"
        }

    ebs_block_device {
      device_name = "/dev/xvdb"
      volume_type = "gp2"
      volume_size = var.app_vol_size
      encrypted = true
    }

    timeouts {
        create = "3m"
        delete = "3m"
    }  
}
