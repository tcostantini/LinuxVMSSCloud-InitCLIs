variable "name" {
  default = ""
}
variable "location" {
  default = ""
}
variable "resource_group_name" {
  default = ""
}
variable "sku" {
  default = ""
}
variable "instances" {
  default = ""
}
variable "admin_username" {
  default = ""
}
variable "ssh_username" {
  default = ""
}
variable "ssh_public_key" {
  default = ""
}
variable "image_publisher" {
  default = ""
}
variable "image_offer" {
  default = ""
}
variable "image_sku" {
  default = ""
}
variable "image_version" {
  default = ""
}
variable "os_disk_storage_account_type" {
  default = ""
}
variable "os_disk_caching" {
  default = ""
}
variable "nic_name" {
  default = ""
}
variable "nic_primary" {
  default = ""
}
variable "ip_config_name" {
  default = ""
}
variable "ip_config_primary" {
  default = ""
}
variable "ip_config_subnet_id" {
  default = ""
}
variable "tags" {
  default = null
}
variable "cloud_config_file_path" {
  default = null
}
variable "overprovision" {
  default = false
}
variable "single_placement_group" {
  default = false
}
variable "storage_account_uri" {
  default = null
}
