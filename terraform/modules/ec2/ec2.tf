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
    "CAPSTONE:Name"      = "${var.resource_name_prefix}-backend-system-sg"
    "TERRAFORM:Resource" = "aws_security_group"
    "TERRAFORM:Module"   = "ec2"
  })
}

resource "aws_instance" "backend_system" {
  ami             = data.aws_ami.ubuntu.id
  instance_type   = "t3.micro"
  subnet_id       = var.backend_system_subnet_id
  security_groups = [aws_security_group.backend_system_sg.name]

  tags = merge(var.tags, {
    "CAPSTONE:Name"      = "${var.resource_name_prefix}-backend-system"
    "TERRAFORM:Resource" = "ec2"
    "TERRAFORM:Module"   = "ec2"
  })

  root_block_device {
    volume_size = 20
    volume_type = "gp3"
    iops        = 3000
    throughput  = 250

    tags = merge(var.tags, {
      "CAPSTONE:Name"      = "${var.resource_name_prefix}-backend-system-block-device"
      "TERRAFORM:Resource" = "aws_instance"
      "TERRAFORM:Module"   = "ec2"
    })
  }
}

resource "aws_ebs_volume" "backend_system_volume" {
  availability_zone = var.backend_system_subnet_az
  size              = 20
  type              = "gp3"
  iops              = 3000
  throughput        = 125

  tags = merge(var.tags, {
    "CAPSTONE:Name"      = "${var.resource_name_prefix}-backend-system-volume"
    "TERRAFORM:Resource" = "aws_ebs_volume"
    "TERRAFORM:Module"   = "ec2"
  })
}

resource "aws_volume_attachment" "backend_system_attachment" {
  device_name = "/dev/sdf"
  volume_id   = aws_ebs_volume.backend_system_volume.id
  instance_id = aws_instance.backend_system.id
}
