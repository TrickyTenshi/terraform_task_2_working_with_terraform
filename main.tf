terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 5.0"
    }
  }
}

resource "azurerm_resource_group" "example" {
  name     = var.resource_group_name
  location = var.location
}

resource "azurerm_storage_account" "example" {
  name                     = var.storage_account_name
  resource_group_name      = azurerm_resource_group.example.name
  location                 = azurerm_resource_group.example.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

data "archive_file" "code_archive" {
  type        = "zip"
  excludes    = [".github", ".terraform", "terraform.tfstate"]
  source_dir  = path.module
  output_path = "${path.module}/../blob.zip"
}

resource "azurerm_storage_container" "example" {
  name                  = var.container_name
  storage_account_id    = azurerm_storage_account.example.id
  container_access_type = "private"
}

resource "azurerm_storage_blob" "example" {
  name                 = var.blob_name
  storage_container_id = azurerm_storage_container.example.id
  type                 = "Block"
  source               = data.archive_file.code_archive.output_path
}