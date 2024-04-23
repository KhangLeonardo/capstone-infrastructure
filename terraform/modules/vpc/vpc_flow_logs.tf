resource "aws_flow_log" "vpc" {
  iam_role_arn    = aws_iam_role.vpc_flow_logs.arn
  log_destination = aws_cloudwatch_log_group.vpc_flow_logs.arn
  traffic_type    = var.vpc_flow_logs_traffic_type
  vpc_id          = aws_vpc.vpc.id

  tags = merge(var.tags, {
    Name         = "${var.resource_name_prefix}-vpc-flow-logs"
    ResourceType = "vpc"
    Module       = "vpc"
  })
}

resource "aws_cloudwatch_log_group" "vpc_flow_logs" {
  name              = "${var.resource_name_prefix}-flow-logs"
  retention_in_days = var.vpc_flow_logs_retention_in_days

  tags = merge(var.tags, {
    ResourceType = "cloudwatch"
    Module       = "vpc"
  })
}

data "aws_iam_policy_document" "vpc_flow_logs_trust" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["vpc-flow-logs.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

data "aws_iam_policy_document" "vpc_flow_logs_cwlogs" {
  statement {
    effect = "Allow"

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:DescribeLogGroups",
      "logs:DescribeLogStreams",
    ]

    resources = ["*"]
  }
}

resource "aws_iam_role" "vpc_flow_logs" {
  name               = "${var.resource_name_prefix}-iam-vpc-flow-logs-role"
  assume_role_policy = data.aws_iam_policy_document.vpc_flow_logs_trust.json

  inline_policy {
    name   = "cwlogs"
    policy = data.aws_iam_policy_document.vpc_flow_logs_cwlogs.json
  }
  
  tags = merge(var.tags, {
    ResourceType = "iam"
    Module       = "vpc"
  })
}