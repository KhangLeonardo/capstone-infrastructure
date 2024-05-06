resource "aws_eip" "this" {
  count = var.enable_eip ? 1 : 0
   domain = "vpc"
   instance = aws_instance.this.id

  tags = merge(var.tags, {
    Name                 = "${var.resource_name_prefix}-jenkins-server-eip"
    "TERRAFORM:Resource" = "aws_eip"
    "TERRAFORM:Module"   = "jenkins"
  })
}
