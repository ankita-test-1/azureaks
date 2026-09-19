terraform {
  required_version = ">= 1.5"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.30"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.13"
    }
  }

  backend "azurerm" {
    resource_group_name  = "tfstate-rg"
    storage_account_name = "akslearntfstate"
    container_name        = "tfstate"
    key                    = "infrastructure-tfstate"
    use_oidc               = true
  }
}

provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
}
