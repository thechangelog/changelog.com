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

variable "default_ssh_user" {
  description = "Default SSH user - for CoreOS this is core, for Ubuntu it is root, not sure about other Linode distros"
  default = "core"
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

data "template_file" "db_mount" {
  template = "${file("${path.module}/volume.mount.tpl")}"

  vars {
    DISK = "${linode_volume.db.filesystem_path}"
    MOUNT_PATH = "/db"
  }
}

resource "linode_volume" "db" {
  region = "${data.linode_region.changelog.id}"
  label = "db"
  size = 10
  linode_id = "${linode_instance.2019.id}"
}

resource "linode_volume" "uploads" {
  region = "${data.linode_region.changelog.id}"
  label = "uploads"
  size = 100
  linode_id = "${linode_instance.2019.id}"
}

data "template_file" "uploads_mount" {
  template = "${file("${path.module}/volume.mount.tpl")}"

  vars {
    DISK = "${linode_volume.uploads.filesystem_path}"
    MOUNT_PATH = "/uploads"
  }
}

resource "null_resource" "mount_volumes" {
  connection {
    user = "${var.default_ssh_user}"
    host = "${linode_instance.2019.ip_address}"
  }

  depends_on = [
    "linode_instance.2019",
    "linode_volume.db",
    "linode_volume.uploads",
  ]

  provisioner "file" {
    content = "${data.template_file.db_mount.rendered}"
    destination = "/tmp/db.mount"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo mv /tmp/db.mount /etc/systemd/system/db.mount",
      "sudo systemctl enable db.mount",
      "sudo systemctl start db.mount",
      "sudo systemctl status db.mount | grep active.*mounted",
    ]
  }

  provisioner "file" {
    content = "${data.template_file.uploads_mount.rendered}"
    destination = "/tmp/uploads.mount"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo mv /tmp/uploads.mount /etc/systemd/system/uploads.mount",
      "sudo systemctl enable uploads.mount",
      "sudo systemctl start uploads.mount",
      "sudo systemctl status uploads.mount | grep active.*mounted",
    ]
  }

  triggers {
    manually = "2018.12.28-16:05"
  }
}

provider "dnsimple" { }

resource "dnsimple_record" "2019" {
  domain = "changelog.com"
  name = "2019"
  value = "${linode_instance.2019.ip_address}"
  type = "A"
  ttl = 60
}
