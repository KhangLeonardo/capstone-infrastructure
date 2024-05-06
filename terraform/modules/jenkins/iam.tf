resource "aws_iam_role" "this" {
  name               = "${var.resource_name_prefix}-jenkins-server-role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      }
    }
  ]
}
EOF
  tags = merge(var.tags, {
    Name                 = "${var.resource_name_prefix}-jenkins-server-role"
    "TERRAFORM:Resource" = "aws_iam_role"
    "TERRAFORM:Module"   = "jenkins"
  })
}

resource "aws_iam_instance_profile" "this" {
  name = aws_iam_role.this.name
  role = aws_iam_role.this.name
}

resource "aws_iam_policy" "this" {
  name        = "${var.resource_name_prefix}-s3-access-policy"
  description = "Allows EC2 instance to download objects from S3"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "s3:GetObject",
          "s3:ListBucket"
        ],
        Resource = [
          "arn:aws:s3:::${aws_s3_bucket.this.bucket}/*",
          "arn:aws:s3:::${aws_s3_bucket.this.bucket}"
        ]
      }
    ]
  })

  tags = {
    Name      = "${var.resource_name_prefix}-s3-access-policy"
    Terraform = "true"
  }
}

resource "aws_iam_role_policy_attachment" "this" {
  role       = aws_iam_role.this.name
  policy_arn = aws_iam_policy.this.arn
}
