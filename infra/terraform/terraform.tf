terraform {
  required_version = ">= 1.3.0"
  required_providers {
    azurerm = {
      version = "> 3.0.0"
    }
  }
}

provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}