terraform {
  required_providers {
    azurerm = "~> 2.99"
  }
}
provider "azurerm" {
  features {}
}


variable "parameters" {
  type        = map(string)
  default     = {
    sites_test_app_for_tf_import_name = "hello-from-terraform"
    sites_test_logicapp_standard_name = "test-tf-logicapp-standard"
  }
}

#
# Consumption Logic App Workflow
# -----------
// resource "azurerm_logic_app_workflow" "logicapp" {
//   name = "tf-logicapp-consumption"
//   location            = "eastus"
//   resource_group_name = "logic-app-sandbox"
// }

#
# Standard Logic App Workflow
# ------------
resource "azurerm_resource_group" "this" {
  name     = "logic-app-tf-sandbox2"
  location = "eastus2"  
}

resource "azurerm_app_service_plan" "this" {
  name                = "tf-la-service-plan"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  kind = "elastic"
  sku {
    tier = "WorkflowStandard"
    size = "WS1"
  }
}

resource "azurerm_storage_account" "this" {
  name                     = "tflasandboxsa"
  resource_group_name      = azurerm_resource_group.this.name
  location                 = azurerm_resource_group.this.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

# Creating logic app standard will create a fileshare on the specified storage account
resource "azurerm_logic_app_standard" "this" {
  name                       = "test-logicapp-standard"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  app_service_plan_id        = azurerm_app_service_plan.this.id
  storage_account_name       = azurerm_storage_account.this.name
  storage_account_access_key = azurerm_storage_account.this.primary_access_key
  storage_account_share_name = "test-logicapp-standard-contents"
}

# Data object to get the ID of the fileshare
data "azurerm_storage_share" "logicapp-fs" {
  name                 = "test-logicapp-standard-contents"
  storage_account_name = azurerm_storage_account.this.name
  depends_on = [azurerm_logic_app_standard.this]
}

resource "azurerm_storage_share_directory" "this" {
  name                 = "site/wwwroot/helloFromLocal"
  share_name           = data.azurerm_storage_share.logicapp-fs.name
  storage_account_name = azurerm_storage_account.this.name
}

output "fs-dir-id" {
  value = azurerm_storage_share_directory.this.id
}

# API Connections must be added as `/site/wwwroot/connections.json`
# Workflows must be added as `/site/wwwroot/<workflowName>/workflow.json` 
resource "azurerm_storage_share_file" "workflow" {
  name             = "${azurerm_storage_share_directory.this.name}/workflow.json"
  storage_share_id = data.azurerm_storage_share.logicapp-fs.id
  source           = "./ARMTemplates/importme/workflow.json"

  depends_on = [azurerm_storage_share_directory.this]
}
