# ACloudGuru's CSAA Course - Terraform Version
> Infrastructure as a Code

# Requirements
- Install Terraform https://www.terraform.io/
- AWS Account https://aws.amazon.com
- ACloudGuru account/subscription http://acloud.guru/

# Tips on AWS Policy

In production environment a simple mistake could wreck your production environment especially when you're still trying out Terraform.

## AWS Organization

Setup a [AWS Organization](https://aws.amazon.com/organizations/) on top of your current account for testing purpose. This is a lot easier

## IAM Permissions

I am using "AWS Organization" for Terraform testing, and I created a special user called `rix@terraform` with a policy of `SystemAdministrator`.

# HowTo

Each directory is independent from other directory. They maintain their own state

## Initialise, Plan it out and Apply

- Go to a folder
  ```
  $> cd ./chapter-8-vpc-part-1
  ```
- On initialise your Terraform project
  ```
  $> terraform init
  ```

- Run "plan" and generate your `.tfstate` file
  ```
  $> terraform plan -var aws_profile="<your aws profile>" -out vpc-plan.tfstate
  ```
- Apply the current Terraform plan
  ```
  $> terraform apply -var aws_profile="<your aws profile>"
  ```

# Chapter 1 - 7
TBA

# Chapter 8

## Part 1

 - VPC
    - Internet Gateway
    - 2 Route Tables
    - Private and Public Subnet
    - 2 EC2 assigned to public and private subnet
    - Remote provisioner for inline Bash command eg. install Apache

## ToDo
- Setup a customise policy file for each chapter/example, rather than using `SystemAdministrator`
- Add more chapter

## Resources
- Provision VPC on Terraform https://github.com/devops-recipes/prov_aws_vpc_terraform
- Amazon Linux AMI https://aws.amazon.com/amazon-linux-ami/
