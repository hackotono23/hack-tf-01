
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
    extra   = "Terraform"
  }
}

//RG
module "RGroups" {
  source          = "./Modules/RGroups"
  tupla_rgname_lc = var.tupla_rgname_lc
}

//Log Analytics
module "LogAnalitycs" {
  source              = "./Modules/Log Analytics"
  name                = var.loganalytics_name
  depends_on          = [module.RGroups]                                    // Dependencia Explicita.
  resource_group_name = join(",", module.RGroups.name[*].RGEU2001.name)     // Dependencia implicita
  location            = join(",", module.RGroups.name[*].RGEU2001.location) // Dependencia implicita
  sku                 = "Standalone"
  //retention_in_days     = 7
  tags = merge(local.common_tags, local.extra_tags)
  solutions = [
    {
      solution_name = "AzureActivity",
      publisher     = "Microsoft",
      product       = "OMSGallery/AzureActivity",
    },
  ]
}

module "SQLServer" {
  source                       = "./Modules/SQL Server"
  depends_on                   = [module.RGroups, module.LogAnalitycs]
  location                     = join(",", module.RGroups.name[*].RGEU2001.location)
  sc_name                      = "holaychao"
  sqlserver_name               = var.sqlserver_name == null ? "sqlserver${random_string.str.result}" : var.sqlserver_name
  db_name                      = var.db_name
  admin_username               = var.admin_username
  admin_password               = var.admin_password
  sql_database_edition         = "Standard"
  sqldb_service_objective_name = "S1"
  resource_group_name          = join(",", module.RGroups.name[*].RGEU2001.name)

  log_analytics_workspace_id = module.LogAnalitycs.resource_id
  log_retention_days         = 7

  firewall_rules = [
    {
      name             = "access-to-azure"
      start_ip_address = "0.0.0.0"
      end_ip_address   = "0.0.0.0"
    },
    {
      name             = "desktop-ip"
      start_ip_address = "190.233.207.107"
      end_ip_address   = "190.233.207.107"
    }
  ]
  tags = merge(local.common_tags, local.extra_tags)
}
