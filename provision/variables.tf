credentials "app.terraform.io" {
  token = var.API_TOKEN
}

terraform {
  backend "remote" {
    organization = "lsy"

    workspaces {
      name = "gitops-demo-2"
    }
  }
}

variable "location" { default = "westeurope" }
variable "vm_prefix" { default = "demovm" }
variable "subnet_id" {}
variable "admin_username" { default = "jedi" }
variable "ssh_public_keys" {}
