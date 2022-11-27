terraform {
  required_version = ">=1.2.5"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=3.28.0"
    }
    cloudinit = {
      source  = "hashicorp/cloudinit"
      version = ">=2.2.0"
    }
  }
}
