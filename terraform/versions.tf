terraform {
  required_providers {
    dnsimple = {
      source = "terraform-providers/dnsimple"
    }
    linode = {
      source = "terraform-providers/linode"
    }
    null = {
      source = "hashicorp/null"
    }
    template = {
      source = "hashicorp/template"
    }
  }
  required_version = ">= 0.13"
}
