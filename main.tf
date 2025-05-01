resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location_id

  //tags are required by resource group
  tags = var.common_tags
}//rg-dsoa-cyberark-terraform-lab-cc

resource "random_string" "resource_code" {
  length  = 3
  special = false
  upper   = false
}

//This will create storage account in corresponding resource group
resource "azurerm_storage_account" "sa" {     
  name                     = var.storage_name
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  tags                     = var.common_tags
  blob_properties {
    last_access_time_enabled = true
  }
}//strgterrazure

resource "azurerm_storage_container" "sc" {
  name                  = "scterra${random_string.resource_code.result}"
  storage_account_name  = azurerm_storage_account.sa.name
  container_access_type = "private"
}

data "azurerm_virtual_network" "vnet" {
  resource_group_name = azurerm_resource_group.rg.name
  name                = var.vnet_name
  //address_space       = ["10.149.0.0/16"]
  //location            = azurerm_resource_group.rg.location
  //tags                = var.common_tags
}//vnet-dsoa-cyberark-terraform-lab-cc

data "azurerm_subnet" "default" {
  //address_prefixes     = ["10.149.0.0/22"]
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = data.azurerm_virtual_network.vnet.name
  name                 = var.subnet_name
}

/* new subnet already created by running this
resource "azurerm_subnet" "test" {
  address_prefixes     = ["10.149.4.0/24"]
  name                 = "test"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = var.vnet_name
}
*/

data "azurerm_subnet" "test" {
  name                 = "test"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = var.vnet_name
}

//Create and Configure an Azure VM Scale Set
resource "azurerm_network_security_group" "vmss" {
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  name                = "nsg-${var.prefix}-vmss"
  tags                = var.common_tags
}//nsg-terraweb-vmss

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
  tags                = var.common_tags
  admin_ssh_key {
    username   = var.admin_username
    public_key = tls_private_key.ssh.public_key_openssh
  }//terraweb-vmss

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

  #Create NIC
  network_interface {
    name                      = "${var.prefix}-nic"
    network_security_group_id = azurerm_network_security_group.vmss.id
    primary                   = true
    ip_configuration {
      name                                   = "primary"
      load_balancer_backend_address_pool_ids = [module.terraweb.azurerm_lb_backend_address_pool_id]
      primary                                = true
      subnet_id                              = data.azurerm_subnet.test.id
    }
  }//terrazure-nic

  health_probe_id = module.terraweb.azurerm_lb_probe_ids[0]

  custom_data = base64encode(templatefile("${path.module}/custom_data.tpl", {
    admin_username = var.admin_username
    port           = var.application_port
  }))

  depends_on = [module.terraweb]
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
  tags              = var.common_tags

  lb_port = {
    http = ["80", "Tcp", "${var.application_port}"]
  }

  lb_probe = {
    http = ["Http", "${var.application_port}", "/"]
  }

}//terraweb-lb

data "azurerm_public_ip" "pip" {
  name                = "terraweb-publicIP"
  resource_group_name = azurerm_resource_group.rg.name
}//terraweb-publicIP

resource "azurerm_network_interface" "nic" {
  name                = "terrazure-nic"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  tags                = var.common_tags
  ip_configuration {
    name                          = "test"
    subnet_id                     = data.azurerm_subnet.test.id
    private_ip_address_allocation = "Dynamic"
  }
}

#Create Virtual Machine
resource "azurerm_virtual_machine" "vm" {
  name                             = "vm-terrazure"
  location                         = azurerm_resource_group.rg.location
  resource_group_name              = azurerm_resource_group.rg.name
  network_interface_ids            = [azurerm_network_interface.nic.id]
  vm_size                          = "Standard_B1s"
  delete_os_disk_on_termination    = true
  delete_data_disks_on_termination = true
  tags                = var.common_tags
  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }

  storage_os_disk {
    name              = "osdisk1"
    disk_size_gb      = "128"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }//osdisk1

  os_profile {
    computer_name  = "vmterrazure"
    admin_username = var.admin_username
    admin_password = var.admin_password
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }

  boot_diagnostics {
    enabled     = "true"
    storage_uri = azurerm_storage_account.sa.primary_blob_endpoint
  }
}//vm-terrazure

//Create an AKS Cluster and Deploy Flux CD Using Helm
module "app" {
  source  = "Azure/aks/azurerm"
  version = "9.4.1"//"8.0.0"

  # Cluster base config
  resource_group_name             = azurerm_resource_group.rg.name
  prefix                          = var.prefix
  cluster_name_random_suffix      = true
  sku_tier                        = "Standard"
  node_os_channel_upgrade         = "NodeImage"
  automatic_channel_upgrade       = "node-image"
  log_analytics_workspace_enabled = false

  # Cluster system pool
  enable_auto_scaling = false
  agents_count        = 2
  agents_size         = "Standard_A2_v2"//"Standard_D2s_v3"
  agents_pool_name    = "systempool"

  # Cluster networking
  vnet_subnet_id = data.azurerm_subnet.test.id //module.aks_vnet.vnet_subnets_name_id["nodes"]
  network_plugin = "azure"
  network_policy = "azure"

  # Cluster node pools
  node_resource_group = "MC_${var.resource_group_name}_${var.prefix}"
  tags = var.common_tags

  node_pools = {
    apppool1 = {
      name           = lower(substr(var.prefix, 0, 8)) # Max of 8 characters and must be lowercase
      vm_size        = "Standard_A2_v2"//"Standard_D2s_v3"
      node_count     = 1
      vnet_subnet_id = data.azurerm_subnet.test.id //module.aks_vnet.vnet_subnets_name_id["nodes"]
    }
  }

  # Cluster Authentication
  local_account_disabled            = false
  role_based_access_control_enabled = true
  rbac_aad                          = false
}

//Deploy Flux CD Using Helm
resource "helm_release" "flux" {
  repository       = "https://fluxcd-community.github.io/helm-charts"
  chart            = "flux2"
  name             = "flux2"
  namespace        = "flux-system"
  create_namespace = true

  depends_on = [module.app]
}
