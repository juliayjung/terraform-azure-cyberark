resource "random_string" "uniquestring" {
  length  = 5
  special = false
  upper   = false
}

resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location_id

  //tags are required by resource group
  tags = var.common_tags
}

//This will create storage account in corresponding resource group
resource "azurerm_storage_account" "storageaccount" {
  name                     = "strterraform${random_string.uniquestring.result}"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

data "azurerm_subnet" "default" {
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = var.vnet_name
  name                 = var.subnet_name
}

//Create and Configure an Azure load balancer
module "terraweb" {
  source  = "Azure/loadbalancer/azurerm"
  version = "4.4.0"

  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location

  type              = "public"
  pip_sku           = "Standard"
  allocation_method = "Static"
  lb_sku            = "Standard"
  prefix            = var.prefix


  lb_port = {
    http = ["80", "Tcp", "${var.application_port}"]
  }

  lb_probe = {
    http = ["Http", "${var.application_port}", "/"]
  }

}

//Create and Configure an Azure VM Scale Set
resource "azurerm_network_security_group" "vmss" {
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  name                = "nsg-${var.prefix}-vmss"
}

resource "azurerm_network_security_rule" "vmss" {
  network_security_group_name = azurerm_network_security_group.vmss.name
  resource_group_name         = azurerm_network_security_group.vmss.resource_group_name
  name                        = "http"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  source_address_prefix       = "*"
  destination_port_range      = var.application_port
  destination_address_prefix  = "*"
}

resource "tls_private_key" "ssh" {
  algorithm = "RSA"
  rsa_bits  = "4096"
}

resource "azurerm_linux_virtual_machine_scale_set" "main" {
  name                = "${var.prefix}-vmss"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                 = var.vm_size
  instances           = var.vmss_count
  admin_username      = var.admin_username

  admin_ssh_key {
    username   = var.admin_username
    public_key = tls_private_key.ssh.public_key_openssh
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }

  os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }

  network_interface {
    name                      = "${var.prefix}-nic"
    network_security_group_id = azurerm_network_security_group.vmss.id
    primary                   = true
    ip_configuration {
      name                                   = "primary"
      load_balancer_backend_address_pool_ids = [module.terraweb.azurerm_lb_backend_address_pool_id]
      primary                                = true
      subnet_id                              = data.azurerm_subnet.default.id
    }
  }

  health_probe_id = module.terraweb.azurerm_lb_probe_ids[0]

  custom_data = base64encode(templatefile("${path.module}/custom_data.tpl", {
    admin_username = var.admin_username
    port           = var.application_port
  }))

  depends_on = [module.terraweb]
}