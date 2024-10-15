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

resource "azurerm_linux_virtual_machine_scale_set" "vmss" {
  name                = "${var.prefix}-vmss-${local.random_id}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  upgrade_policy_mode = "Manual"
  sku {
    name     = "Standard_DS1_v2"
    tier     = "Standard"
    capacity = var.vmss_capacity
  }

  os_profile {
    computer_name_prefix = "${var.prefix}-vmss"
    admin_username       = "azureuser"
    custom_data          = filebase64("${path.module}/cloud-init.txt")
  }

  os_profile_linux_config {
    disable_password_authentication = true
    ssh_keys {
      path     = "/home/azureuser/.ssh/authorized_keys"
      key_data = tls_private_key.ssh.public_key_openssh
    }
  }

  storage_profile_image_reference {
    id = "/subscriptions/${var.subscription_id}/resourceGroups/${azurerm_resource_group.rg.name}/providers/Microsoft.Compute/images/autogpt-vm-image"
  }

  storage_profile_os_disk {
    caching              = "ReadWrite"
    managed_disk_type    = "Premium_LRS"
    disk_size_gb         = 30
  }

  network_profile {
    name    = "${var.prefix}-vmss-nic"
    primary = true
    ip_configuration {
      name                                   = "${var.prefix}-vmss-ipconfig"
      subnet_id                              = azurerm_subnet.snet.id
      primary                                = true
      public_ip_address_configuration {
        name = "${var.prefix}-vmss-pip"
      }
    }
  }

  automatic_instance_repair {
    enabled      = true
    grace_period = "PT30M"
  }

  health_probe_id = azurerm_lb_probe.lb_probe.id

  depends_on = [
    null_resource.packer
  ]

  lifecycle {
    replace_triggered_by = [
      null_resource.packer
    ]
  }
}

resource "azurerm_monitor_autoscale_setting" "autoscale" {
  name                = "${var.prefix}-autoscale"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  target_resource_id  = azurerm_linux_virtual_machine_scale_set.vmss.id

  profile {
    name = "defaultProfile"
    capacity {
      default = var.vmss_capacity
      minimum = var.vmss_min_capacity
      maximum = var.vmss_max_capacity
    }

    rule {
      metric_trigger {
        metric_name        = "Percentage CPU"
        metric_resource_id = azurerm_linux_virtual_machine_scale_set.vmss.id
        time_grain         = "PT1M"
        statistic          = "Average"
        time_window        = "PT5M"
        time_aggregation   = "Average"
        operator           = "GreaterThan"
        threshold          = 75
      }

      scale_action {
        direction = "Increase"
        type      = "ChangeCount"
        value     = "1"
        cooldown  = "PT1M"
      }
    }

    rule {
      metric_trigger {
        metric_name        = "Percentage CPU"
        metric_resource_id = azurerm_linux_virtual_machine_scale_set.vmss.id
        time_grain         = "PT1M"
        statistic          = "Average"
        time_window        = "PT5M"
        time_aggregation   = "Average"
        operator           = "LessThan"
        threshold          = 25
      }

      scale_action {
        direction = "Decrease"
        type      = "ChangeCount"
        value     = "1"
        cooldown  = "PT1M"
      }
    }
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
