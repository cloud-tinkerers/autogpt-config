locals {
  random_id = random_id.rid.hex
  user_path = "/home/azureuser"
}

resource "random_id" "rid" {
  byte_length = 3
}

resource "azurerm_resource_group" "rg" {
  name     = "${var.prefix}-rg"
  location = "eastus"
}

resource "azurerm_storage_account" "my_storage_account" {
  name                     = "diag${local.random_id}"
  location                 = azurerm_resource_group.rg.location
  resource_group_name      = azurerm_resource_group.rg.name
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

# Create (and display) an SSH key
resource "tls_private_key" "ssh" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "azurerm_linux_virtual_machine" "vm" {
  name                  = "${var.prefix}-vm-${local.random_id}"
  location              = azurerm_resource_group.rg.location
  resource_group_name   = azurerm_resource_group.rg.name
  network_interface_ids = [azurerm_network_interface.nic.id]
  size                  = "Standard_DS1_v2"
  source_image_id       = "/subscriptions/${var.subscription_id}/resourceGroups/${azurerm_resource_group.rg.name}/providers/Microsoft.Compute/images/autogpt-vm-image"


  os_disk {
    name                 = "${var.prefix}-vm-disk-${local.random_id}"
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  computer_name                   = "${var.prefix}-pc"
  admin_username                  = "azureuser"
  disable_password_authentication = true

  admin_ssh_key {
    username   = "azureuser"
    public_key = tls_private_key.ssh.public_key_openssh
  }

  boot_diagnostics {
    storage_account_uri = azurerm_storage_account.my_storage_account.primary_blob_endpoint
  }

  connection {
    type        = "ssh"
    host        = self.public_ip_address
    user        = self.admin_username
    private_key = tls_private_key.ssh.private_key_pem
    timeout     = "2m"
  }

  provisioner "file" {
    source = "${path.module}/autogpt.env"
    destination = "/tmp/autogpt.env"
  }

  provisioner "remote-exec" {
    inline = [
      "echo 'Contents of /tmp:'",
      "ls -la /tmp",
      "echo 'Contents of ${local.user_path}/Auto-GPT:'",
      "ls -la ${local.user_path}/Auto-GPT",
      "sudo mkdir -p ${local.user_path}/Auto-GPT",
      "sudo mv /tmp/autogpt.env ${local.user_path}/Auto-GPT/.env",
      "echo 'Contents of ${local.user_path}/Auto-GPT after moving file:'",
      "ls -la ${local.user_path}/Auto-GPT",
    ]
  }

  depends_on = [
    null_resource.packer
  ]

  lifecycle {
    replace_triggered_by = [
      null_resource.packer
    ]
  }
}

resource "local_file" "private_key" {
  filename        = "${path.module}/id_rsa"
  content         = tls_private_key.ssh.private_key_pem
  file_permission = "0600"
}

resource "local_file" "autogpt_env" {
  content = local.autogpt_env
  filename = "${path.module}/autogpt.env"
}
