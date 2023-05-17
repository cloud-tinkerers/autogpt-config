locals{  
  autogpt_env = templatefile("${path.module}/.env.tpl", {
    OPENAI_API_KEY = var.openai_api_key
  })
}

resource "null_resource" "packer" {
  provisioner "local-exec" {
    command = "packer build -force -var 'client_id=${var.client_id}' -var 'client_secret=${var.client_secret}' -var 'subscription_id=${var.subscription_id}' -var 'tenant_id=${var.tenant_id}' -var 'resource_group=${azurerm_resource_group.rg.name}' ../packer/autogpt.pkr.hcl"
  }

  triggers = {
    client_id       = var.client_id
    client_secret   = var.client_secret
    subscription_id = var.subscription_id
    tenant_id       = var.tenant_id
    resource_group  = azurerm_resource_group.rg.name
  }
}