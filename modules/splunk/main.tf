data "aws_iam_policy_document" "splunk_aws_ro_role_document" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals = {
      type        = "AWS"
      identifiers = ["arn:aws:iam::779799343306:role/SplunkRole"]
    }
  }
}

resource "aws_iam_role" "splunk_aws_ro_role" {
  name   = "SplunkAWSRORole"
  policy = "${data.aws_iam_policy_document.splunk_aws_ro_role_document.json}"
}

data "aws_iam_policy_document" "splunk_aws_ro_policy_document" {
  statement {
    actions = [
      "ec2:DescribeInstances",
      "ec2:DescribeReservedInstances",
      "ec2:DescribeSnapshots",
      "ec2:DescribeRegions",
      "ec2:DescribeKeyPairs",
      "ec2:DescribeNetworkAcls",
      "ec2:DescribeSecurityGroups",
      "ec2:DescribeSubnets",
      "ec2:DescribeVolumes",
      "ec2:DescribeVpcs",
      "ec2:DescribeImages",
      "ec2:DescribeAddresses",
      "lambda:ListFunctions",
      "rds:DescribeDBInstances",
      "cloudfront:ListDistributions",
      "iam:GetUser",
      "iam:ListUsers",
      "iam:GetAccountPasswordPolicy",
      "iam:ListAccessKeys",
      "iam:GetAccessKeyLastUsed",
      "elasticloadbalancing:DescribeLoadBalancers",
      "elasticloadbalancing:DescribeInstanceHealth",
      "elasticloadbalancing:DescribeTags",
      "elasticloadbalancing:DescribeTargetGroups",
      "elasticloadbalancing:DescribeTargetHealth",
      "elasticloadbalancing:DescribeListeners",
      "s3:ListAllMyBuckets",
      "s3:GetAccelerateConfiguration",
      "s3:GetBucketCORS",
      "s3:GetLifecycleConfiguration",
      "s3:GetBucketLocation",
      "s3:GetBucketLogging",
      "s3:GetBucketTagging",
    ]

    resources = [
      "*",
    ]
  }

  statement {
    actions = [
      "config:DescribeConfigRules",
      "config:DescribeConfigRuleEvaluationStatus",
      "config:GetComplianceDetailsByConfigRule",
      "config:GetComplianceSummaryByConfigRule",
    ]

    resources = [
      "*",
    ]
  }

  statement {
    actions = [
      "inspector:Describe*",
      "inspector:List*",
    ]

    resources = [
      "*",
    ]
  }
}

resource "aws_iam_role_policy" "splunk_aws_ro_role" {
  name   = "SplunkROPolicy"
  role   = "${aws_iam_role.splunk_aws_ro_role.id}"
  policy = "${data.aws_iam_policy_document.splunk_aws_ro_policy_document.json}"
}

