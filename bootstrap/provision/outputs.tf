output "jenkins-pip" {
  description = "Public endpoint of the Jenkins master"
  value       = azurerm_public_ip.jenkins-pip.ip_address
}
