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

resource "linode_instance" "2019" {
  region = "${data.linode_region.changelog.id}"
  type = "${data.linode_instance_type.changelog.id}"
  label = "${var.generation}"
  image = "${data.linode_image.changelog.id}"
  authorized_users = ["gerhard-changelog", "jerodsanto", "adamstac"]
  private_ip = true
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
    instance_id = "${linode_instance.2019.id}"
  }
}

resource "null_resource" "init_docker_swarm" {
  connection {
    user = "${var.default_ssh_user}"
    host = "${linode_instance.2019.ip_address}"
  }

  depends_on = [
    "linode_instance.2019",
  ]

  provisioner "remote-exec" {
    inline = [
      "docker swarm init",
    ]
  }

  triggers {
    manually = "2018.12.29-16:12"
    instance_id = "${linode_instance.2019.id}"
  }
}

# https://github.com/terraform-providers/terraform-provider-linode/issues/23
resource "null_resource" "configure_private_ip_manually_since_containerlinux_doesnt_support_network_helper" {
  connection {
    user = "${var.default_ssh_user}"
    host = "${linode_instance.2019.ip_address}"
  }

  depends_on = [
    "linode_instance.2019",
  ]

  provisioner "remote-exec" {
    inline = [
      "grep -q Address /etc/systemd/network/05-eth0.network || (echo -e '\nAddress=${linode_instance.2019.private_ip_address}/17\n' | sudo tee -a /etc/systemd/network/05-eth0.network)",
      "sudo sed -i 's|^Address=.*$|Address=${linode_instance.2019.private_ip_address}/17|g' /etc/systemd/network/05-eth0.network",
      "sudo systemctl daemon-reload",
      "sudo systemctl restart systemd-networkd"
    ]
  }

  triggers {
    manually = "2019.01.03-01:23"
    private_ip = "${linode_instance.2019.private_ip_address}"
  }
}

# https://www.linode.com/docs/platform/nodebalancer/getting-started-with-nodebalancers-new-manager/
# https://linode.com/docs/platform/nodebalancer/nodebalancer-reference-guide-new-manager/
resource "linode_nodebalancer" "2019" {
  label = "${var.generation}"
  region = "${data.linode_region.changelog.id}"
}

resource "linode_nodebalancer_config" "http_2019" {
  nodebalancer_id = "${linode_nodebalancer.2019.id}"
  port = 80
  protocol = "http"
  check = "http"
  check_interval = 20
  check_timeout = 10
  check_attempts = 3
  check_path = "/"
  check_passive = true
  stickiness = "table"
  algorithm = "leastconn"
}

resource "linode_nodebalancer_node" "http_2019" {
  label = "${var.generation}"
  address = "${linode_instance.2019.private_ip_address}:80"
  mode = "accept"
  nodebalancer_id = "${linode_nodebalancer.2019.id}"
  config_id = "${linode_nodebalancer_config.http_2019.id}"
}

resource "linode_nodebalancer_config" "https_2019" {
  nodebalancer_id = "${linode_nodebalancer.2019.id}"
  port = 443
  protocol = "https"
  check = "http"
  check_interval = 20
  check_timeout = 10
  check_attempts = 3
  check_path = "/"
  check_passive = true
  stickiness = "table"
  algorithm = "leastconn"
  cipher_suite = "recommended"
  ssl_key = "${var.ssl_key}"
  ssl_cert = "${var.ssl_cert}"
}
resource "linode_nodebalancer_node" "https_2019" {
  label = "${var.generation}"
  address = "${linode_instance.2019.private_ip_address}:80"
  mode = "accept"
  nodebalancer_id = "${linode_nodebalancer.2019.id}"
  config_id = "${linode_nodebalancer_config.https_2019.id}"
}

provider "dnsimple" { }

resource "dnsimple_record" "2019" {
  domain = "changelog.com"
  name = "${var.generation}"
  value = "${linode_nodebalancer.2019.ipv4}"
  type = "A"
  ttl = 60
}

resource "dnsimple_record" "2019i" {
  domain = "changelog.com"
  name = "${var.generation}i"
  value = "${linode_instance.2019.ip_address}"
  type = "A"
  ttl = 60
}
