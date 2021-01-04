# aviAws

## Goals
Spin up a full AWS/Avi environment (through Terraform) with Route 53 integration and multi AZ VS.

## Prerequisites:
- Terraform installed in the orchestrator VM
- AWS credential/details are configured as environment variable:
```
AWS_DEFAULT_REGION=eu-west-1
AWS_SECRET_ACCESS_KEY=****************************
AWS_ACCESS_KEY_ID=****************************
TF_VAR_accessKeyAws=****************************
TF_VAR_secretKeyAws=****************************
TF_VAR_regionAws=eu-west-1
```
- DNS route 53 hosted zone configured in var.domain.name
- SSH key configured in var.public_key_path and var.privateKey

## Environment:
Terraform plan has/have been tested against:

### terraform
```
Terraform v0.14.3
+ provider registry.terraform.io/hashicorp/aws v3.22.0
+ provider registry.terraform.io/hashicorp/null v3.0.0
+ provider registry.terraform.io/hashicorp/template v2.2.0
```

### Avi version
```
Avi 20.1.2
```

### AWS Region:
eu-west-1

## Input/Parameters:
All the paramaters/variables are stored in variables.tf

## Use the terraform plan to:
- Create the IAM object for Avi (Policy, Role) and for the jump server
- Create the AWS Network infrastructure (VPC, Internet gateway, Subnet, Route Table, Security Groups) - there are two routing tables (one which allows NAT through the NAT gateway - the other does not)
- Spin up a jump server with ansible installed - userdata to install package - mgt subnet - elastic IP
- Spin up an Avi Controller - mgt subnet - elastic IP
- Spin up backend servers (one per AZ) - backend subnet - userdata to run basic http service
- Spin up auto scaling group (one with 3 servers - one per AZ) - backend subnet - userdata to run basic http service
- Spin up two opencart backend server
- Spin up one mysql backend server
- Register the FQDN of the jump server and the Avi Controller on the hosted zone
- Create a yaml variable file - in the jump server
- Call ansible to do the configuration (opencart app) based on dynamic inventory
- Call ansible to do the configuration (avi) based on dynamic inventory

## Run the terraform:
```
cd ~ ; git clone https://github.com/tacobayle/aviAws ; cd aviAws ; terraform init ; terraform apply -auto-approve
# the terraform will output the command to destroy the environment.
```
