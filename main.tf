terraform {
  required_version = "1.2.5"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.28.0"
    }
    cloudinit = {
      source  = "hashicorp/cloudinit"
      version = "2.2.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "4.0.4"
    }
  }

  backend "azurerm" {}
}

provider "azurerm" {
  features {}
}

variable "ssh_private_key" {
  sensitive = true
}

locals {
  prefix   = "vmsscloudinit"
  location = "uksouth"

  vmsss = [
    {
      name                         = "${local.prefix}"
      sku                          = "Standard_DS1_v2"
      instances                    = 1
      admin_username               = "serveradmin"
      ssh_username                 = "serveradmin"
      image_publisher              = "canonical"
      image_offer                  = "0001-com-ubuntu-server-focal"
      image_sku                    = "20_04-lts-gen2"
      image_version                = "latest"
      os_disk_storage_account_type = "Standard_LRS"
      os_disk_caching              = "ReadWrite"
      nic_name                     = "${local.prefix}-nic"
      nic_primary                  = true
      ip_config_name               = "internal"
      ip_config_primary            = true
      cloud_config_file_path       = "${path.root}/cloud-config/cloud-config.yaml"
      overprovision                = false
      single_placement_group       = false
      storage_account_uri          = null
    },
  ]
}

data "tls_public_key" "private_key_openssh" {
  private_key_openssh = file(var.ssh_private_key)
}

resource "azurerm_resource_group" "main" {
  name     = "${local.prefix}-rg"
  location = local.location

  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}

resource "azurerm_virtual_network" "vnet" {
  name                = "${local.prefix}-network"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}

resource "azurerm_subnet" "subnet" {
  name                 = "${local.prefix}-subnet"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

module "linux_vmss" {
  for_each                     = { for vmss in local.vmsss : vmss.name => vmss }
  source                       = "./modules/tf-azurerm-linux-vmss"
  name                         = each.key
  location                     = local.location
  resource_group_name          = azurerm_resource_group.main.name
  sku                          = each.value.sku
  instances                    = each.value.instances
  admin_username               = each.value.admin_username
  ssh_username                 = each.value.ssh_username
  ssh_public_key               = data.tls_public_key.private_key_openssh.public_key_openssh
  image_publisher              = each.value.image_publisher
  image_offer                  = each.value.image_offer
  image_sku                    = each.value.image_sku
  image_version                = each.value.image_version
  os_disk_storage_account_type = each.value.os_disk_storage_account_type
  os_disk_caching              = each.value.os_disk_caching
  nic_name                     = each.value.nic_name
  nic_primary                  = each.value.nic_primary
  ip_config_name               = each.value.ip_config_name
  ip_config_primary            = each.value.ip_config_primary
  ip_config_subnet_id          = azurerm_subnet.subnet.id
  cloud_config_file_path       = each.value.cloud_config_file_path
  overprovision                = each.value.overprovision
  single_placement_group       = each.value.single_placement_group
  storage_account_uri          = each.value.storage_account_uri
}
