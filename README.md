# CloudForge - Terraform

## Folder Structure
- `policies/` used to store manually created policies.
- `container-definitions/` used to store container definitions that needed by ECS Task Definition.
- `doc/` used to store specified documentation
- `modules` used to store custom modules.

## Security
#### SCP
I use SCP (Service control policies) to enable central administration over the permissions available within the accounts in our organization. All the policies are in this [folder](policies/SCP).

#### User Management
I use IAM Identity Center to manage our users.

## Resources This repo will deploy
  - VPC
  - subnets
  - Security Groups
  - ALB
  - Target Groups
  - NAT gateway
  - Internet Gateway
  - ECS
    - Task Definition
    - ECS Service
  - EC2 (BastionHost)
  - Private Key (BastionHost)
  - RDS
  - EFS (Sonarqube)
  - CodeDeploy (blue/green)
  - IAM User
    - (ecs-user)


### Security Guides
- [How to Setup Federated Authentication using Google Workspace and IAM Identity Center](https://aws.amazon.com/blogs/security/how-to-set-up-federated-single-sign-on-to-aws-using-google-workspace/)
- [How to manage permissions in IAM Identity Center](https://www.Illarchitectedlabs.com/cost/100_labs/100_1_aws_account_setup/4_configure_sso/)
- [How To Bastion host is setup](https://www.strongdm.com/blog/bastion-hosts-with-audit-logging-part-one)
- [Encrypting client connections to MySQL DB instances with SSL/TLS](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/mysql-ssl-connections.html)

TODO: Replace Bastion host with (Tailscale)
- [Tailscale Terraform](https://tailscale.com/blog/terraform/)
- [Tailscale Terraform Fargate](https://blog.bossylobster.com/2022/08/tailscale-terraform-fargate.html)

### Sonarqube setup (Development)
Based on this [sonarqube documentation](https://docs.sonarqube.org/latest/setup-and-upgrade/install-the-server/) I've used to deploy sonarqube using terraform to ECS cluster, and after its installed, this is the next step you must do.

- go to installed sonarqube to your specified domain, to setup initial user.
- after setup initial user, login with that user.
- start scanning your applications, the sonarqube ui will guide you. 

# Prework

## AWS Setup
- Create a user that has admin privilieges. All the terraform action need AWS Admin Privileges.
- Push all the docker images to ECR, How to upload image to ECR will be explained in this [doc](doc/HowToAddNewApp.md)
- Request an certificates at ACM, save the arn that will be used in terraform cloud variable.

## Pre - Configure

- Create workspace in terraform cloud
- Create backend.tf
- Add these lines
```
terraform {
  cloud {
    organization = "cloud"

    workspaces {
      name = "<workspace-name>"
    }
  }
}
```

# Deployment Notes

### VCS

- Create these variables in terraform cloud
  - acm_certificate_arn
  - env
  > Value: `Production` or `Development`
  - aws_access_key
  - aws_secret_key
  - aws_session_token
  - include_db_replica (bool) 
  > Value: `true` for `Production`, `false` for `Development`
  - include_sonarqube (bool) 
  > Value: `true` for `Production`, `false` for `Development`
  - rds_sonarqube_password (development)
  > for development create random password, and check sensitive checkbox, for production leave it empty string "".
  - aws_production_id (AWS Production Account ID)
  - aws_development_id (AWS Development Account ID)
  - aws_common_id (AWS Common Account ID)
- edit variables.tf as needed, or leave it as is

### CLI

- Create these variables in terraform cloud
  - acm_certificate_arn
  - env
  > Value: `Production` or `Development`
  - include_db_replica (bool) 
  > Value: `true` for `Production`, `false` for `Development`
  - include_sonarqube (bool) 
  > Value: `true` for `Production`, `false` for `Development`
  - rds_sonarqube_password (development)
  > for development create random password, and check sensitive checkbox, for production leave it empty string "".
  - aws_production_id (AWS Production Account ID)
  - aws_development_id (AWS Development Account ID)
  - aws_common_id (AWS Common Account ID)
- Login to AWS SSO
- Choose `Common` Account
- click `Command line or programmatic access`
- copy export command
- and then run this command `source exportAwsCredsCommon.sh`
- back to AWS SSO, copy export command from `Development` or `Production` Account
- paste and execute to your terminal
- and then run this command `source exportAwsCreds.sh`
- edit variables.tf as needed, or leave it as is

## Deployment

- terraform init
- terraform apply
> On terrafrom cloud VCS, just push code to configured repo or trigger from terraform cloud UI

### Retrieve sensitive output

- `terraform output -raw rds_password`
- `terraform output -raw private_key` (BastionHost)
- `terraform output -raw ecs_user_secret`

## Cleanup

Run `./cleanupEnv.sh` to cleanup the env variables so they don't linger on system.

# Notes
### RDS Public Read Replica
In production I deploy a read replica of the cloud-infra database so that it can be read from Google Data Studio. Manual steps here: https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/USER_ReadRepl.html#USER_ReadRepl.Create

# CloudForgestructure Deployment with Terraform

This repository showcases my ability to deploy and manage CloudForgestructure using Terraform. It leverages various AWS services to create a robust and scalable environment for running applications.

## Key Components

- **Application Load Balancer (ALB):** `alb.tf` defines the ALB for distributing traffic to the application.
- **Bastion Host:** `bastion-host.tf` configures a secure bastion host for administrative access.
- **Content Delivery Network (CDN):** `cdn.tf` and `cdn-role.tf` set up CloudFront for efficient content delivery.
- **Containerization with ECS:** `ecs.tf`, `ecs-service.tf`, `task-definition.tf`, and related files manage the Elastic Container Service cluster and task deployments.
- **Relational Database Service (RDS):** `rds.tf` configures the database instance.
- **Elastic File System (EFS):** `efs.tf` provides scalable file storage.
- **IAM Roles and Users:** Various `*.tf` files define IAM roles and users for secure access and permissions.
- **Security Groups:** `security-groups.tf` defines the network security rules.
- **Service Discovery with Cloud Map:** `cloudmap.tf` enables service discovery within the VPC.
- **Secrets Management:** `secret-manager.tf` manages sensitive information.
- **S3 Buckets:** `s3.tf` configures storage buckets.
- **CloudWatch Logging:** `cloudwatch-log-group.tf` sets up log groups for monitoring.

## Deployment Process

The deployment is managed using Terraform:

1. **Initialization:** `terraform init` sets up the working directory and downloads required providers.
2. **Planning:** `terraform plan` previews the changes to be made.
3. **Application:** `terraform apply` applies the changes to create the infrastructure.

## Cleanup

The `cleanupEnv.sh` script is provided for easy removal of the deployed resources. Alternatively, `terraform destroy` can be used.

## Configuration Files

- `main.tf`: Main configuration file.
- `backend.tf`: Configures the Terraform state backend.
- `outputs.tf`: Defines output variables.
- `*.tf`: Other files define specific resources and configurations.

This repository demonstrates my ability to design, deploy, and manage Cloud infrastructure structure using Terraform effectively.