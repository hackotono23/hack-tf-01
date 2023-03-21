
terraform {
  backend "azurerm" {
    resource_group_name  = "tfstate"
    storage_account_name = "sttfstate12223322"
    container_name       = "tfstate"
    key                  = "prod.terraform.tfstate"
  }
  required_providers {
    azurerm = {
      version = "~> 2.19"
    }
  }
}



provider "azurerm" {
  features {}
}

//Generation of ramdom String App Service
resource "random_string" "str" {
  length  = 3
  special = false
  upper   = false
  number  = false
}
//Declaration of Locals Variables.
locals {

  common_tags = {
    environment = "${var.prefix}"
    project     = "${var.project}"
    Terraform   = "true"
    Environment = "dev"
    Owner       = "test-user"
  }
  extra_tags = {
    network = "HackTest"
    extra = "Terraform"
  }
}

//RG
module "RGroups" {
  source = "./Modules/RGroups"
  tupla_rgname_lc = var.tupla_rgname_lc
}