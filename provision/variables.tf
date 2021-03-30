terraform {
  backend "remote" {
    organization = "lsy"

    workspaces {
      name = "gitops-demo-2"
    }
  }
}
