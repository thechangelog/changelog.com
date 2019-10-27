variable "linode_token" {
  description = "Linode APIv4 Personal Access Token: https://cloud.linode.com/profile/tokens"
}

variable "linode_region" {
  description = "Region in which resources will be provisioned: us-west (Fremont), us-central (Dallas), us-southeast (Atlanta), us-east (Newark), eu-west (London), eu-central (Frankfurt), ap-south (Singapore), ap-northeast (Tokyo 1), ap-northeast-1a (Tokyo 2)"
  default = "us-east"
}

variable "linode_instance_type" {
  description = "Instance type to provision for the app instance: https://api.linode.com/v4/linode/types https://www.linode.com/pricing#all"
  default = "g6-standard-8"
}

variable "default_ssh_user" {
  description = "Default SSH user - for CoreOS this is core, for Ubuntu it is root, not sure about other Linode distros"
  default = "core"
}

variable "ssl_key" {
  description = "changelog.com SSL private key"
}

variable "ssl_cert" {
  description = "changelog.com SSL certificate"
}

variable "generation" {
  description = "The date this stack went into production"
  default = "2019"
}

data "linode_region" "changelog" {
  id = "${var.linode_region}"
}

data "linode_instance_type" "changelog" {
  id = "${var.linode_instance_type}"
}

data "linode_image" "changelog" {
  id = "linode/containerlinux"
}
