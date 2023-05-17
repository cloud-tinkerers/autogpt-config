variable "client_id" {
  type        = string
  description = "Azure Client ID"
}

variable "client_secret" {
  type        = string
  description = "Azure Client Secret"
}

variable "subscription_id" {
  type        = string
  description = "Azure Subscription ID"
}

variable "tenant_id" {
  type        = string
  description = "Azure Tenant ID"
}

variable "resource_group" {
  type        = string
  description = "Azure Resource Group"
}

source "azure-arm" "autogpt" {
  client_id                     = var.client_id
  client_secret                 = var.client_secret
  subscription_id               = var.subscription_id
  tenant_id                     = var.tenant_id
  managed_image_resource_group_name = var.resource_group
  managed_image_name            = "autogpt-vm-image"
  os_type                       = "Linux"
  image_publisher               = "Canonical"
  image_offer                   = "0001-com-ubuntu-server-jammy"
  image_sku                     = "22_04-lts-gen2"
  location                      = "East US"
  vm_size                       = "Standard_DS1_v2"
  communicator                  = "ssh"
  ssh_username                  = "azureuser"
}

build {
  sources = [
    "source.azure-arm.autogpt"
  ]
  
  provisioner "shell" {
    inline = [
      "export DEBIAN_FRONTEND=noninteractive",
      "sudo apt clean",
      "sudo apt update",
      "sudo apt install -y ca-certificates containerd curl runc python3 python3-pip git",
      "sudo update-alternatives --install /usr/bin/python python /usr/bin/python3 10",
      "curl -fsSL https://get.docker.com -o get-docker.sh",
      "sudo sh get-docker.sh",
      "sudo systemctl enable docker",
      "sudo systemctl start docker",
      "sudo usermod -aG docker azureuser",
      "git clone https://github.com/Significant-Gravitas/Auto-GPT.git",
      "cd Auto-GPT",
      "pip install --user -r requirements.txt"
    ]
  }
}
  