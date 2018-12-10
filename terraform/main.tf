provider "linode" {
  token = "${var.linode_token}"
}

variable "linode_token" {
  description = "Linode APIv4 Personal Access Token: https://cloud.linode.com/profile/tokens"
}

variable "linode_region" {
  description = "Region in which resources will be provisioned: us-west (Fremont), us-central (Dallas), us-southeast (Atlanta), us-east (Newark), eu-west (London), eu-central (Frankfurt), ap-south (Singapore), ap-northeast (Tokyo 1), ap-northeast-1a (Tokyo 2)"
  default = "us-east"
}

variable "linode_instance_type" {
  description = "Instance type to provision for the app instance: https://www.linode.com/pricing#all"
  default = "g6-standard-2"
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

resource "linode_instance" "2019" {
  region = "${data.linode_region.changelog.id}"
  type = "${data.linode_instance_type.changelog.id}"
  label = "2019"
  image = "${data.linode_image.changelog.id}"
  authorized_users = ["gerhard-changelog"]
}
