provider "linode" {
  token = var.linode_token
  version = "~> 1.3"
}

provider "dnsimple" {
  version = "~> 0.1"
}

provider "null" {
  version = "~> 2.0"
}

provider "template" {
  version = "~> 2.0"
}

