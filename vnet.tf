resource "azurerm_virtual_network" "this" {
  name                = "${local.prefix}-vnet"
  location            = var.region
  resource_group_name = azurerm_resource_group.this.name
  address_space       = ["10.0.0.0/16"]
  dns_servers         = ["10.0.0.4", "10.0.0.5"]

  subnet {
    name           = "${local.prefix}-private-subnet-1"
    address_prefix = "10.0.1.0/24"
    security_group = azurerm_network_security_group.this.id
  }

  subnet {
    name           = "${local.prefix}-private-subnet-2"
    address_prefix = "10.0.2.0/24"
    security_group = azurerm_network_security_group.this.id
  }

  tags = { 
    environment = "dev"
  }
}

