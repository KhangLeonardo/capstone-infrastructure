output "jenkins_ssh_private_key" {
  value     = module.jenkins.jenkins_ssh_private_key
  sensitive = true
}

output "jenkins_ssh_public_key" {
  value     = module.jenkins.jenkins_ssh_public_key
  sensitive = true
}

output "jenkins_server_dns" {
  value = module.jenkins.jenkins_server_dns
}
