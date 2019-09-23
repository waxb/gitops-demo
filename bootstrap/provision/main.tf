#0. step; create credentials
#az ad sp create-for-rbac -n "infra-builder" --role contributor
provider "azurerm" {
  subscription_id 	= var.subscription_id
  client_id 		    = var.client_id
  client_secret    	= var.client_secret
  tenant_id 		    = var.tenant_id
}

locals {
  location = "westeurope"
  env_name = "infra-rg"
  vm_name  = "jenkins-master"
}

#1. create infra resource group
resource "azurerm_resource_group" "infra_rg" {
  name      = local.env_name
  location  = local.location
}

#2. create infra storage account for state files and boot diagnostics
resource "azurerm_storage_account" "test" {
  name                     = "infrastgaccforthingz"
  resource_group_name      = azurerm_resource_group.infra_rg.name
  location                 = azurerm_resource_group.infra_rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

#3. create VNET with one subnet
resource "azurerm_virtual_network" "test" {
  name                = "virtualNetwork"
  location            = azurerm_resource_group.infra_rg.location
  resource_group_name = azurerm_resource_group.infra_rg.name
  address_space       = ["10.0.0.0/16"]

  subnet {
    name           = "subnet"
    address_prefix = "10.0.0.0/16"
  }
}
#4. create the orchestrator VM (Jenkins)
resource "azurerm_public_ip" "jenkins-pip" {
  name                = "jenkins-pip"
  resource_group_name = azurerm_resource_group.infra_rg.name
  location            = azurerm_resource_group.infra_rg.location
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "main" {
  name                = "${local.vm_name}-nic"
  location            = azurerm_resource_group.infra_rg.location
  resource_group_name = azurerm_resource_group.infra_rg.name

  ip_configuration {
    name                          = "ipconfig"
    subnet_id                     = element(azurerm_virtual_network.test.subnet.*.id, 0)
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.jenkins-pip.id
  }
}

resource "azurerm_virtual_machine" "main" {
  name                  = local.vm_name
  location              = azurerm_resource_group.infra_rg.location
  resource_group_name   = azurerm_resource_group.infra_rg.name
  network_interface_ids = ["${azurerm_network_interface.main.id}"]
  vm_size               = "Standard_B2s"

  delete_os_disk_on_termination = true
  delete_data_disks_on_termination = true

  storage_image_reference {
    publisher       = "OpenLogic"
    offer           = "CentOS"
    sku             = "7.6"
    version         = "latest"
  }

  storage_os_disk {
    name              = "myosdisk1"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = local.vm_name
    admin_username = "jedi"
    admin_password = var.ssh_public_key
  }

  os_profile_linux_config {
    disable_password_authentication = true
    ssh_keys {
        path     = "/home/jedi/.ssh/authorized_keys"
        key_data = "${var.ssh_public_key}"
    }
  }
}
