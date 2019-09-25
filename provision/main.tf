module "rg" {
  source  = "adfinis-forks/resource-group/azurerm"
  version = "0.0.0"


  location = var.location
  name     = "demo-rg"
}

resource "azurerm_public_ip" "lb-pip" {
  name                = "lb-pip"
  resource_group_name = module.rg.name
  location            = var.location
  allocation_method   = "Static"
}

module "loadbalancer" {
  source = "git::https://github.com/waxb/tf-lb-azure.git"
  #global definition
  rg_name   = module.rg.name
  location  = var.location
  subnet_id = var.subnet_id
  pip_id    = azurerm_public_ip.lb-pip.id
  #local definition
  loadbalancer_name = "APP_LOAD_BALANCER"
  protocol          = "tcp"
  ports             = ["80"]
}

module "avset" {
  source  = "git::https://github.com/waxb/tf-as-azure.git"

  location                = var.location

  availability_set_name   = "app_server_avset"
  pfdc                    = 2
  pudc                    = 2
}

module "vm_apps" {
  source = "git::https://github.com/waxb/tf-vm-ans-azure.git"

  vm_count = 2

  #global definition
  location        = var.location
  vm_prefix       = "${var.vm_prefix}app"
  subnet_id       = var.subnet_id
  admin_username  = var.admin_username
  ssh_public_keys = var.ssh_public_keys

  #local definition
  rg_name                           = module.rg.name
  vm_size                           = "Standard_B1s"
  os_acc_type                       = "Standard_LRS"
  os_disk_size                      = "10"
  stg_acc_type                      = "Standard_LRS"
  data_disk_size                    = "0"
  data_disk_count                   = "0"
  publisher                         = "OpenLogic"
  offer                             = "CentOS"
  sku                               = "7.6"
  im_version                        = "latest"
  dosdisk                           = "true"
  ddadisk                           = "false"
  disable_password_authentication   = "false"
  backend_pool_id                   = module.loadbalancer.backend_address_pool_id
  availability_set_id               = module.avset.availability_set_id

  group_name = "app_servers"
}
