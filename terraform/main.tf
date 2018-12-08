variable "linode_token" {
  description = "Linode APIv4 Personal Access Token: https://cloud.linode.com/profile/tokens"
}

provider "linode" {
  token = "${var.linode_token}"
}

data "linode_region" "main" {
  id = "us-east"
}

data "linode_instance_type" "default" {
  id = "g6-standard-2"
}

data "linode_image" "ubuntu" {
  id = "linode/containerlinux"
}
