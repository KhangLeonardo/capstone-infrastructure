##########################################
# S3 Bucket
##########################################

resource "aws_s3_bucket" "this" {
  bucket        = "${var.resource_name_prefix}-${var.bucket_name}"
  force_destroy = true

    tags = merge(var.tags, {
      "TERRAFORM:Resource" = "aws_s3_bucket"
      "TERRAFORM:Module"   = "jenkins"
    })
}

##########################################
# S3 Bucket Ownership Controls
##########################################

resource "aws_s3_bucket_ownership_controls" "this" {
  bucket = aws_s3_bucket.this.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

##########################################
# S3 Bucket Public Access Block
##########################################

resource "aws_s3_bucket_public_access_block" "this" {
  bucket = aws_s3_bucket.this.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

##########################################
# S3 Bucket ACL
##########################################

resource "aws_s3_bucket_acl" "this" {
  depends_on = [
    aws_s3_bucket_ownership_controls.this,
    aws_s3_bucket_public_access_block.this,
  ]

  bucket = aws_s3_bucket.this.id
  acl    = "private"
}

##########################################
# S3 Bucket Policy
##########################################

resource "aws_s3_bucket_policy" "this" {
  bucket = aws_s3_bucket.this.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "Allow-access-from-specific-VPCE"
        Effect    = "Allow"
        Principal = "*"
        Action    = ["s3:GetObject", "s3:ListBucket"]
        Resource  = [
          "${aws_s3_bucket.this.arn}",
          "${aws_s3_bucket.this.arn}/*"
        ]
        Condition = {
          StringEquals = {
            "aws:sourceVpce" = "${var.vpc_s3_endpoint}"
          }
        }
      }
    ]
  })
}

##########################################
# S3 Objects
##########################################

# resource "aws_s3_object" "this" {
#   for_each = fileset("${path.module}/src", "**/*")

#   bucket = aws_s3_bucket.this.bucket
#   key    = each.value
#   source = "${path.module}/src/${each.value}"
# }

resource "aws_s3_object" "env_file" {
  bucket   = aws_s3_bucket.this.bucket
  key      = ".env"
  source   = "${path.module}/src/.env"
  metadata = {
    md5 = filemd5("${path.module}/src/.env")
  }
}

resource "aws_s3_object" "compose_file" {
  bucket   = aws_s3_bucket.this.bucket
  key      = "docker-compose.yaml"
  source   = "${path.module}/src/docker-compose.yaml"
  metadata = {
    md5 = filemd5("${path.module}/src/docker-compose.yaml")
  }
}
