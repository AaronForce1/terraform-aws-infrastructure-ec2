# Terraform Infrastructure Provisioning for Legacy EC2 Instances in AWS

## Overview
As we slowly transition away from Ansible scripts and manual AWS instance provisioning, from the command line, we're setting up standards for EC2 provisioning that can be used for all internal / client-facing applications that require "legacy" EC2 infrastructure (as opposed to more advanced Kubernetes/Containerised deployments). 

### Example Applications that leverage AsiaTicketing - Terraform EC2
- Gitlab EE
- Tableau Server
- Client SFTP Servers

### Infrastructure Managed
In order of provisioning:

- VPC, Subnets, Route Tables, Internet Gatways
- Security Groups
- EC2 VMs

# Local Env Setup
Terraform can work directly from your local CLI or via Gitlab CI/CD. State files are currently stored in AWS S3.

## AWS S3 Bucket Defaults:
```
S3 REGION = ap-southeast-1
KEY = $TF_VAR_app_name/$TF_VAR_tfenv/terraform.tfstate
S3 BUCKET = ets-terraform-remote-state-storage-s3
```
You can specify these manually, or pass them directly to terraform init.

## Setup
1. `terraform init`
```
terraform init -backend-config "region=ap-southeast-1" \
          -backend-config "key=$TF_VAR_app_name/$TF_VAR_tfenv/terraform.tfstate" \ 
          -backend-config "bucket=ets-terraform-remote-state-storage-s3" \
          -backend-config "encrypt=true"
```
2. `terraform plan`
> You will need to specify App Name, App Slug, and AWS Region where you want your app to deploy

> `output` is optional for `terraform plan`, but is helpful to prepare local state for apply 
3. `terraform apply`
4. `terraform destroy`
> Will require the same inputs as `terraform apply` in order to fetch the correct state data from S3 or locally and destroy the instance.

# Gitlab CI CD
The pipeline can be queued manually from Gitlab via the Pipelines > Run Pipeline prompt. The following environment variables will need to be defined on each manual run.
- `TF_VAR_tfenv={test,stag,prod}`
- `TF_VAR_app_name` _eg. Gitlab, Tableau Server, etc._
- `TF_VAR_app_slug` _eg. gitlab, tableau, melco-sftp, etc._
- `TF_VAR_aws_region` _eg. ap-northeast-2, ap-southeast-1, etc._

# Environment Variables Available
