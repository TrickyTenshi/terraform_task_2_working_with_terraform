terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 5.0"
    }
  }
}

resource "azurerm_resource_group" "example" {
  name     = var.azcname
  location = var.azclocation
}

resource "azurerm_storage_account" "example" {
  name                     = var.saccname
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
  name                  = "content"
  storage_account_id    = azurerm_storage_account.example.id
  container_access_type = "private"
}

resource "azurerm_storage_blob" "example" {
  name                 = "my-awesome-content.zip"
  storage_container_id = azurerm_storage_container.example.id
  type                 = "Block"
  source               = data.archive_file.code_archive.output_path
}