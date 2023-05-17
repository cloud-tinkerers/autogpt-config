output "ssh_connection_string" {
  value = "ssh -i ${path.module}/infra/terraform/id_rsa azureuser@${azurerm_public_ip.pip.ip_address}"
}

output "resource_group_name" {
  value = azurerm_resource_group.rg.name
}

output "public_ip" {
  value = azurerm_public_ip.pip.ip_address
}

output "public_ip_address" {
  value = azurerm_linux_virtual_machine.vm.public_ip_address
}

output "tls_private_key" {
  value     = tls_private_key.ssh.private_key_pem
  sensitive = true
}

# output "fqdn" {
#   value = azurerm_dns_a_record.a.fqdn
# }
