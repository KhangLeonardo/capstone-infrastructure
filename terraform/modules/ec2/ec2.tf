resource "aws_iam_role" "backend_system_iam_role" {
  name = "${var.resource_name_prefix}-backend-system-iam-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = merge(var.tags, {
    "Name"               = "${var.resource_name_prefix}-backend-system-iam-role"
    "TERRAFORM:Resource" = "aws_iam_role"
    "TERRAFORM:Module"   = "ec2"
  })
}

resource "aws_iam_role_policy_attachment" "cloudwatch_logs" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM"
  role       = aws_iam_role.backend_system_iam_role.name
}

resource "aws_iam_role_policy_attachment" "cloudwatch_put_logs" {
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
  role       = aws_iam_role.backend_system_iam_role.name
}

resource "aws_iam_instance_profile" "backend_system_instace_profile" {
  name = "${var.resource_name_prefix}-backend-system-instance-profile"
  role = aws_iam_role.backend_system_iam_role.name

  tags = merge(var.tags, {
    "Name"               = "${var.resource_name_prefix}-backend-system-instance-profile"
    "TERRAFORM:Resource" = "aws_iam_instance_profile"
    "TERRAFORM:Module"   = "ec2"
  })
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"]
}

resource "aws_security_group" "backend_system_sg" {
  name        = "${var.resource_name_prefix}-backend-system-sg"
  vpc_id      = var.vpc_id
  description = "Security group for backend system"

  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    "Name"               = "${var.resource_name_prefix}-backend-system-sg"
    "TERRAFORM:Resource" = "aws_security_group"
    "TERRAFORM:Module"   = "ec2"
  })
}

resource "aws_instance" "backend_system" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t3.medium"
  subnet_id              = var.backend_system_subnet_id
  vpc_security_group_ids = [aws_security_group.backend_system_sg.id]
  iam_instance_profile   = aws_iam_instance_profile.backend_system_instace_profile.name

  user_data = <<-EOF
              #!/bin/bash
              sudo yum update -y
              sudo yum install -y awslogs

              cat <<-EOF2 >> /etc/awslogs/awslogs.conf
              [general]
              state_file = /var/lib/awslogs/agent-state

              [/var/log/messages]
              log_group_name = /var/log/messages
              log_stream_name = {instance_id}
              datetime_format = %b %d %H:%M:%S
              EOF2

              sudo systemctl enable awslogsd
              sudo systemctl start awslogsd
              EOF

  tags = merge(var.tags, {
    "Name"               = "${var.resource_name_prefix}-backend-system"
    "TERRAFORM:Resource" = "aws_instance"
    "TERRAFORM:Module"   = "ec2"
  })

  root_block_device {
    volume_size = 50
    volume_type = "gp3"
    iops        = 3000
    throughput  = 250

    tags = merge(var.tags, {
      "Name"               = "${var.resource_name_prefix}-backend-system-block-device"
      "TERRAFORM:Resource" = "root_block_device"
      "TERRAFORM:Module"   = "ec2"
    })
  }
}
