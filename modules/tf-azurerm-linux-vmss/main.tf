data "cloudinit_config" "config" {
  gzip          = true
  base64_encode = true

  part {
    content_type = "text/cloud-config"
    content      = file(var.cloud_config_file_path)
  }
}

resource "azurerm_linux_virtual_machine_scale_set" "vmss" {
  name                   = var.name
  resource_group_name    = var.resource_group_name
  location               = var.location
  sku                    = var.sku
  instances              = var.instances
  admin_username         = var.admin_username
  overprovision          = var.overprovision
  single_placement_group = var.single_placement_group
  tags                   = var.tags

  admin_ssh_key {
    username   = var.ssh_username
    public_key = var.ssh_public_key
  }

  source_image_reference {
    publisher = var.image_publisher
    offer     = var.image_offer
    sku       = var.image_sku
    version   = var.image_version
  }

  os_disk {
    storage_account_type = var.os_disk_storage_account_type
    caching              = var.os_disk_caching
  }

  network_interface {
    name    = var.nic_name
    primary = var.nic_primary

    ip_configuration {
      name      = var.ip_config_name
      primary   = var.ip_config_primary
      subnet_id = var.ip_config_subnet_id
    }
  }

  boot_diagnostics {
    storage_account_uri = var.storage_account_uri
  }

  custom_data = data.cloudinit_config.config.rendered

  lifecycle {
    ignore_changes = [
      instances,
      tags
    ]
  }
}
