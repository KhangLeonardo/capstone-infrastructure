resource "tls_private_key" "this" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "aws_key_pair" "this" {
  key_name   = "jenkins-server-key"
  public_key = tls_private_key.this.public_key_openssh
}

resource "aws_instance" "this" {
  ami                  = var.ami
  instance_type        = var.instance_type
  subnet_id            = var.public_subnet_ids[0]
  key_name             = aws_key_pair.this.key_name
  security_groups      = [aws_security_group.this.id]
  iam_instance_profile = aws_iam_instance_profile.this.name
  user_data            = file("${path.module}/userdata/jenkins-server-userdata.sh")
  tags = merge(var.tags, {
    Name                 = "${var.resource_name_prefix}-jenkins-server-instance"
    "TERRAFORM:Resource" = "aws_instance"
    "TERRAFORM:Module"   = "jenkins"
  })

  root_block_device {
    volume_size = 50
    volume_type = "gp3"
    iops        = 3000
    throughput  = 250

    tags = merge(var.tags, {
      "Name"               = "${var.resource_name_prefix}-jenkins-server-block-device"
      "TERRAFORM:Resource" = "root_block_device"
      "TERRAFORM:Module"   = "jenkins"
    })
  }

  lifecycle {
    ignore_changes = [
      security_groups,
      user_data
    ]
  }

  depends_on = [aws_s3_bucket.this]
}

resource "aws_security_group" "this" {
  name        = "${var.resource_name_prefix}-jenkins-server-security-group"
  vpc_id      = var.vpc_id
  description = "Security group for Jenkins Server instance"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "SSH connection"
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTP connection"
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTPS connection"
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Jenkins dashboard connection"
  }

  ingress {
    from_port   = 9090
    to_port     = 9090
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "App server connection"
  }

  ingress {
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "PGAdmin4 dashboard connection"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }

  tags = merge(var.tags, {
    Name                 = "${var.resource_name_prefix}-jenkins-server-security-group"
    "TERRAFORM:Resource" = "aws_security_group"
    "TERRAFORM:Module"   = "jenkins"
  })
}
