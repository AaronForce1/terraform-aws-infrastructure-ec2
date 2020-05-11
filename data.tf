data "aws_ami" "ubuntu" {
    most_recent = true

    filter {
        name   = "name"
        values = ["ubuntu/images/hvm-ssd/ubuntu-*20.04-amd64-server-*"]
    }

    filter {
        name   = "virtualization-type"
        values = ["hvm"]
    }

    owners = [ var.ubuntu_owner ] # Canonical
}

data "aws_availability_zones" "azs" {
}

# data "terraform_remote_state" "state" {
#   backend = "s3"
#   config = {
#     bucket     = "ets-terraform-remote-state-storage-s3"
#     encrypt    = true
#     region     = "ap-southeast-1"
#     key        = "${var.app_name}/${var.tfenv}/terraform.tfstate"
#   }
# }