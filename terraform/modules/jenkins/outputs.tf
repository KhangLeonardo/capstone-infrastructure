output "jenkins_ssh_private_key" {
  value     = tls_private_key.this.private_key_pem
  sensitive = true
}

output "jenkins_ssh_public_key" {
  value     = aws_key_pair.this.public_key
  sensitive = true
}

output "jenkins_server_dns" {
  value = aws_instance.this.public_dns
}
