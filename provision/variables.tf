terraform {
  backend "azurerm" {
    storage_account_name = "infrastgaccforthingz"
    container_name       = "infrastg"
    resource_group_name  = "infrarg"
    key                  = "terraform.ptest.tfstate"
  }
}

variable "location" { default = "westeurope" }
variable "vm_prefix" { default = "demovm"}
variable "subnet_id" { default = "/subscriptions/b9e037b8-0e49-4a95-9032-0f2ded839c84/resourceGroups/infra-rg/providers/Microsoft.Network/virtualNetworks/virtualNetwork/subnets/subnet" }
variable "admin_username" { default = "jedi" }
variable "ssh_public_keys" { default = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDK7c8zbwqybYCEH0udxciJNpr3IJ4zUXpPqD7+5FQbPkHN+SLrRS50c96K/6/f2lz78qQfiuR+4R5b/Spgv8NxyEggnQuItAQk5g1kmjGToVtxr8FQoPi37xBoDRtJE3typdPSj5Mz5NXXRlWeRaVqv664og23x2ucDGJJK6Z4rsKpn+L9ChhP8znPy2iW+0eKUBK3c6KFXS4kxMpfoj5TFVePgk4VE+NMFA1joF2yn+O5CbSf9d6mEvlQ99pmFyBH5m3Uo2cig0nbXjFL/Fmg5q5BfuZCF0XSiVpi5a+lB1rxnGCe+Uv02/fRz3CaR1shtzp6ZWO5TS0Pa4925HQH jenkins@jenkins-master" }
