resource "awscc_iam_role" "cloudability_role" {
  role_name = var.role_name
  
  assume_role_policy_document = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": {
          "AWS": "arn:aws:iam::${var.trusted_account_id}:user/${var.user}"
        },
        "Action": "sts:AssumeRole",
        "Condition": {
          "StringEquals": {
            "sts:ExternalId": var.external_id
          }
        }
      }
    ]
  })
  
  policies = [
    {
      policy_name = "CloudabilityVerificationPolicy"
      policy_document = jsonencode({
        "Version": "2012-10-17",
        "Statement": [
          {
            "Sid": "VerifyRolePermissions",
            "Effect": "Allow",
            "Action": "iam:SimulatePrincipalPolicy",
            "Resource": "arn:aws:iam::*:role/${var.role_name}"
          }
        ]
      })
    },
    {
      policy_name = "CloudabilityManagementAccountPolicy"
      policy_document = jsonencode({
        "Version": "2012-10-17",
        "Statement": [
          {
            "Effect": "Allow",
            "Action": [
              "s3:ListBucket",
              "s3:GetObject"
            ],
            "Resource": [
              "arn:aws:s3:::${var.bucket_name}",
              "arn:aws:s3:::${var.bucket_name}/*"
            ]
          },
          {
            "Effect": "Allow",
            "Action": [
              "organizations:ListAccounts",
              "organizations:ListTagsForResource"
            ],
            "Resource": "*"
          }
        ]
      })
    },
    {
      policy_name = "CloudabilityMonitorResourcesPolicy"
      policy_document = jsonencode({
        "Version": "2012-10-17",
        "Statement": [
          {
            "Effect": "Allow",
            "Action": [
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
            ],
            "Resource": "*"
          }
        ]
      })
    }
  ]
}
