resource "azurerm_resource_group" "this" {
  name     = "${local.prefix}-resourcegroup"
  location = var.region
  tags = { 
    environment = "dev"
  }
}

