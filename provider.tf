terraform {
  required_version = ">= 0.13"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 2.25.0"
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

resource "random_string" "random_rg" {
  length  = 4
  upper   = false
  special = false
}

resource "azurerm_resource_group" "rg-aula" {
  name     = "rg-aula-${random_string.random_rg.result}"
  location = var.location

  tags = {
    environment = "aula infra"
  }
}
