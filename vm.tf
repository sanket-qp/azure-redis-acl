data "azurerm_subnet" "this" {
  name                 = "${local.prefix}-private-subnet-1"
  virtual_network_name = "${local.prefix}-vnet"
  resource_group_name  = azurerm_resource_group.this.name
}

resource "azurerm_public_ip" "this" {
  name                = "${local.prefix}-public-ip"
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  allocation_method   = "Dynamic"
}

resource "azurerm_network_security_group" "this" {
  name                = "${local.prefix}-security-group"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name

  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_interface" "this" {
  name                = "${local.prefix}-nic"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name

  ip_configuration {
    name                          = "${local.prefix}-ipconfig"
    subnet_id                     = data.azurerm_subnet.this.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.this.id
  }

  depends_on = [
    azurerm_public_ip.this
  ]
}

# Connect the security group to the network interface
resource "azurerm_network_interface_security_group_association" "this" {
  network_interface_id      = azurerm_network_interface.this.id
  network_security_group_id = azurerm_network_security_group.this.id
}

resource "azurerm_linux_virtual_machine" "this" {
  name                = "${local.prefix}-vm"
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  size                = "Standard_B1s"
  admin_username      = "redisdemo"
  network_interface_ids = [
    azurerm_network_interface.this.id,
  ]

  identity {
    type         = "UserAssigned"
    identity_ids = tolist([azurerm_user_assigned_identity.admin.id, azurerm_user_assigned_identity.user.id])
  }

  admin_ssh_key {
    username   = "redisdemo"
    public_key = tls_private_key.this.public_key_openssh
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }

  depends_on = [
    azurerm_user_assigned_identity.admin,
    azurerm_user_assigned_identity.user,
    azurerm_network_interface.this,
    tls_private_key.this
  ]
}

