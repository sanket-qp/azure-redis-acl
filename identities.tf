resource "azurerm_user_assigned_identity" "admin" {
  location            = azurerm_resource_group.this.location
  name                = "${local.prefix}-redis-admin-mi"
  resource_group_name = azurerm_resource_group.this.name
}

resource "azurerm_user_assigned_identity" "user" {
  location            = azurerm_resource_group.this.location
  name                = "${local.prefix}-redis-user-mi"
  resource_group_name = azurerm_resource_group.this.name
}

