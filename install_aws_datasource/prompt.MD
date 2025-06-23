# CloudFormation to Terraform (AWSCC Provider) Conversion Guide

## Overview

This prompt outlines the steps to convert the `role-cloud-formation.yaml` CloudFormation template into Terraform code using the AWS CloudControl (AWSCC) provider.

## Key Requirements

1. **Always use the latest AWSCC provider version**
   - Do not specify a version constraint in your configurations
   - Always run `terraform init -upgrade` to get the latest provider

2. **Automatically apply changes after validation**
   - Always use `terraform apply -auto-approve` immediately after successful validation and planning
   - This ensures immediate implementation of infrastructure changes

## What is the AWSCC Provider?

The AWSCC (AWS CloudControl) provider allows you to use AWS CloudFormation resource types directly in Terraform. This provides several advantages:

- Direct 1:1 mapping from CloudFormation resources to Terraform resources
- Access to all CloudFormation resource types
- Consistent with CloudFormation behavior and functionality

## Prerequisites

1. Terraform installed (version 1.0.0 or later)
2. AWS CLI configured with appropriate credentials
3. Basic understanding of Terraform syntax and structure

## Conversion Process

### 1. Create the Terraform Configuration Files

Create the following files:

- `main.tf` - Main resource definitions
- `variables.tf` - Variable declarations
- `terraform.tfvars` - Variable values (optional)
- `outputs.tf` - Output definitions (optional)
- `providers.tf` - Provider configuration
- `versions.tf` - Terraform and provider version constraints


### 2. Set Up the Provider Configuration in `providers.tf`

```hcl
provider "awscc" {
  region = "us-east-1"  # Change to your desired AWS region
}
```

**IMPORTANT**: The provider version should be configured in the `versions.tf` file (see next section) and should always use the latest available version.

### 2.5. Configure Version Constraints in `versions.tf`

While you can include version constraints in the `providers.tf` file, it's often good practice to separate them into a dedicated `versions.tf` file for better organization:

```hcl
terraform {
  required_version = ">= 1.0.0"
  required_providers {
    awscc = {
      source  = "hashicorp/awscc"
      # Always use the latest version of the AWSCC provider
      # Do not specify a version constraint to ensure you always get the latest
    }
    # You can include other providers here if needed
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}
```

Using a separate `versions.tf` file allows you to:

- Keep all version constraints in one place
- More easily update version requirements
- Maintain cleaner organization in larger projects with multiple providers

**IMPORTANT**: Always use the latest version of the AWSCC provider to ensure you have the most recent features and bug fixes.

### 3. Define Variables in `variables.tf`

Convert the CloudFormation parameters to Terraform variables:

```hcl
variable "role_name" {
  type        = string
  description = "The name of the role Cloudability will use"
  default     = "CloudabilityRole"
}

variable "bucket_name" {
  type        = string
  description = "The bucket where your cost files are kept"
  default     = "cloudabilityslynch"
}

variable "trusted_account_id" {
  type        = string
  description = "The Cloudability account this role will trust"
  default     = "165736516723"
}

variable "external_id" {
  type        = string
  description = "The external identifier to use, given to you by Cloudability"
  default     = "2884068b-fa40-4cec-aafd-a215e98532c2"
}

variable "user" {
  type        = string
  description = "User to be added to Trustee Relationship"
  default     = "cloudability"
}
```

### 4. Create the IAM Role Resource in `main.tf`

Convert the CloudFormation Role resource to Terraform AWSCC resource:

```hcl
resource "awscc_iam_role" "cloudability_role" {
  role_name = var.role_name
  
  assume_role_policy_document = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${var.trusted_account_id}:user/${var.user}"
        }
        Action = "sts:AssumeRole"
        Condition = {
          StringEquals = {
            "sts:ExternalId" = var.external_id
          }
        }
      }
    ]
  })
  
  policies = [
    {
      policy_name = "CloudabilityVerificationPolicy"
      policy_document = jsonencode({
        Version = "2012-10-17"
        Statement = {
          Sid    = "VerifyRolePermissions"
          Effect = "Allow"
          Action = "iam:SimulatePrincipalPolicy"
          Resource = "arn:aws:iam::*:role/${var.role_name}"
        }
      })
    },
    {
      policy_name = "CloudabilityManagementAccountPolicy"
      policy_document = jsonencode({
        Version = "2012-10-17"
        Statement = [
          {
            Effect = "Allow"
            Action = [
              "s3:ListBucket",
              "s3:GetObject"
            ]
            Resource = [
              "arn:aws:s3:::${var.bucket_name}",
              "arn:aws:s3:::${var.bucket_name}/*"
            ]
          },
          {
            Effect = "Allow"
            Action = [
              "organizations:ListAccounts",
              "organizations:ListTagsForResource"
            ]
            Resource = "*"
          }
        ]
      })
    },
    {
      policy_name = "CloudabilityMonitorResourcesPolicy"
      policy_document = jsonencode({
        Version = "2012-10-17"
        Statement = [
          {
            Effect = "Allow"
            Action = [
              "cloudwatch:GetMetricStatistics",
              "dynamodb:DescribeTable",
              "dynamodb:ListTables",
              "ec2:DescribeImages",
              "ec2:DescribeInstances",
              "ec2:DescribeRegions",
              "ec2:DescribeReservedInstances",
              "ec2:DescribeReservedInstancesModifications",
              "ec2:DescribeSnapshots",
              "ec2:DescribeVolumes",
              "ec2:GetReservedInstancesExchangeQuote",
              "ecs:DescribeClusters",
              "ecs:DescribeContainerInstances",
              "ecs:ListClusters",
              "ecs:ListContainerInstances",
              "elasticache:DescribeCacheClusters",
              "elasticache:DescribeReservedCacheNodes",
              "elasticache:ListTagsForResource",
              "elasticmapreduce:DescribeCluster",
              "elasticmapreduce:ListClusters",
              "elasticmapreduce:ListInstances",
              "rds:DescribeDBClusters",
              "rds:DescribeDBInstances",
              "rds:DescribeReservedDBInstances",
              "rds:ListTagsForResource",
              "redshift:DescribeClusters",
              "redshift:DescribeReservedNodes",
              "redshift:DescribeTags",
              "redshift:DescribeClusterSnapshots",
              "savingsplans:DescribeSavingsPlans",
              "ce:GetSavingsPlansPurchaseRecommendation",
              "lambda:ListFunctions",
              "lambda:ListProvisionedConcurrencyConfigs",
              "s3:ListAllMyBuckets"
            ]
            Resource = "*"
          }
        ]
      })
    }
  ]
}
```

### 5. Add Outputs in `outputs.tf` (Optional)

```hcl
output "role_arn" {
  description = "The ARN of the created IAM role"
  value       = awscc_iam_role.cloudability_role.arn
}

output "role_name" {
  description = "The name of the created IAM role"
  value       = awscc_iam_role.cloudability_role.role_name
}
```

### 6. Testing the Conversion

1. Initialize Terraform with the latest provider version:

   ```bash
   terraform init -upgrade
   ```

2. Validate the configuration:

   ```bash
   terraform validate
   ```

3. Plan the deployment and apply immediately upon successful validation:

   ```bash
   terraform plan && terraform apply -auto-approve
   ```

**IMPORTANT**: Always use `terraform apply -auto-approve` to automatically apply changes after successful planning. This ensures immediate implementation of your infrastructure changes.

**Alternative one-liner for production pipelines**:

```bash
terraform init -upgrade && terraform validate && terraform plan && terraform apply -auto-approve
```

### 7. Important Notes

- **Always use the latest AWSCC provider version** - Do not specify a version constraint
- **Always run with auto-approve** - Use `terraform apply -auto-approve` immediately after successful validation
- The AWSCC provider follows CloudFormation semantics, which may differ from the standard AWS provider
- Some resource attributes might need adjustments based on AWSCC provider requirements
- Check for any warnings or errors during validation and planning

## Resources

- [AWSCC Provider Documentation](https://registry.terraform.io/providers/hashicorp/awscc/latest/docs)
- [AWS CloudFormation Resource Types Reference](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-template-resource-type-ref.html)
- [Terraform Auto-Approve Documentation](https://developer.hashicorp.com/terraform/cli/commands/apply#auto-approve)
