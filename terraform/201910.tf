resource "linode_instance" "prod_2019_10" {
  region = data.linode_region.changelog.id
  type = data.linode_instance_type.changelog.id
  label = "prod_2019_10"
  image = data.linode_image.changelog.id
  authorized_users = ["gerhard-changelog", "jerodsanto", "adamstac"]
  private_ip = true
}

resource "linode_volume" "db_2019_10" {
  region = data.linode_region.changelog.id
  label = "db_2019_10"
  size = 10
  linode_id = linode_instance.prod_2019_10.id

  # Reject with an error any plan that would destroy the infrastructure object associated with the resource
  # https://www.terraform.io/docs/configuration/resources.html#prevent_destroy
  lifecycle {
    prevent_destroy = true
  }
}

data "template_file" "db_2019_10_mount" {
  template = "${file("${path.module}/volume.mount.tpl")}"

  vars = {
    DISK = "${linode_volume.db_2019_10.filesystem_path}"
    MOUNT_PATH = "/db"
  }
}

resource "linode_volume" "uploads_2019_10" {
  region = data.linode_region.changelog.id
  label = "uploads_2019_10"
  size = 100
  linode_id = linode_instance.prod_2019_10.id

  # Reject with an error any plan that would destroy the infrastructure object associated with the resource
  # https://www.terraform.io/docs/configuration/resources.html#prevent_destroy
  lifecycle {
    prevent_destroy = true
  }
}

data "template_file" "uploads_2019_10_mount" {
  template = "${file("${path.module}/volume.mount.tpl")}"

  vars = {
    DISK = linode_volume.uploads_2019_10.filesystem_path
    MOUNT_PATH = "/uploads"
  }
}

resource "null_resource" "mount_volumes_2019_10" {
  connection {
    user = var.default_ssh_user
    host = linode_instance.prod_2019_10.ip_address
  }

  depends_on = [
    linode_instance.prod_2019_10,
    linode_volume.db_2019_10,
    linode_volume.uploads_2019_10,
  ]

  provisioner "file" {
    content = data.template_file.db_2019_10_mount.rendered
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
    content = data.template_file.uploads_2019_10_mount.rendered
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

  triggers = {
    manually = "2019_10.03-21:17"
    instance_id = linode_instance.prod_2019_10.id
  }
}

resource "null_resource" "init_docker_swarm_2019_10" {
  connection {
    user = var.default_ssh_user
    host = linode_instance.prod_2019_10.ip_address
  }

  depends_on = [
    linode_instance.prod_2019_10,
  ]

  provisioner "remote-exec" {
    inline = [
      "docker swarm init",
    ]
  }

  triggers = {
    manually = "2019_10.03-21:17"
    instance_id = linode_instance.prod_2019_10.id
  }
}

# https://github.com/terraform-providers/terraform-provider-linode/issues/23
resource "null_resource" "configure_private_ip_manually_since_containerlinux_doesnt_support_network_helper_2019_10" {
  connection {
    user = var.default_ssh_user
    host = linode_instance.prod_2019_10.ip_address
  }

  depends_on = [
    linode_instance.prod_2019_10,
  ]

  provisioner "remote-exec" {
    inline = [
      "grep -q Address /etc/systemd/network/05-eth0.network || (echo -e '\nAddress=${linode_instance.prod_2019_10.private_ip_address}/17\n' | sudo tee -a /etc/systemd/network/05-eth0.network)",
      "sudo sed -i 's|^Address=.*$|Address=${linode_instance.prod_2019_10.private_ip_address}/17|g' /etc/systemd/network/05-eth0.network",
      "sudo systemctl daemon-reload",
      "sudo systemctl restart systemd-networkd"
    ]
  }

  triggers = {
    manually = "2019_10.03-21:17"
    private_ip = linode_instance.prod_2019_10.private_ip_address
  }
}

# It would have been nice to disable these via Ignition, but this is not supported on Linode...
# https://www.linode.com/community/questions/427/help-i-am-running-coreos-and-need-to-add-custom-cloud-config
resource "null_resource" "disable_automatic_updates_2019_10" {
  connection {
    user = var.default_ssh_user
    host = linode_instance.prod_2019_10.ip_address
  }

  depends_on = [
    linode_instance.prod_2019_10,
  ]

  provisioner "remote-exec" {
    inline = [
      "sudo systemctl disable update-engine",
      "sudo systemctl stop update-engine",
      "systemctl is-active --quiet update-engine || echo 'OK: Update Engine is not active'",
    ]
  }

  triggers = {
    always = "${timestamp()}"
  }
}

# https://www.linode.com/docs/platform/nodebalancer/getting-started-with-nodebalancers-new-manager/
# https://linode.com/docs/platform/nodebalancer/nodebalancer-reference-guide-new-manager/
resource "linode_nodebalancer" "prod_2019_10" {
  label = "prod_2019_10"
  region = data.linode_region.changelog.id
}

resource "linode_nodebalancer_config" "prod_2019_10_http" {
  nodebalancer_id = linode_nodebalancer.prod_2019_10.id
  port = 80
  protocol = "http"
  check = "http"
  check_interval = 20
  check_timeout = 10
  check_attempts = 3
  check_path = "/"
  check_passive = false
  stickiness = "table"
  algorithm = "leastconn"
}

resource "linode_nodebalancer_node" "prod_2019_10_http" {
  label = "prod_2019_10_http"
  address = "${linode_instance.prod_2019_10.private_ip_address}:80"
  mode = "accept"
  nodebalancer_id = linode_nodebalancer.prod_2019_10.id
  config_id = linode_nodebalancer_config.prod_2019_10_http.id
}

resource "linode_nodebalancer_config" "prod_2019_10_https" {
  nodebalancer_id = linode_nodebalancer.prod_2019_10.id
  port = 443
  protocol = "https"
  check = "http"
  check_interval = 20
  check_timeout = 10
  check_attempts = 3
  check_path = "/"
  check_passive = false
  stickiness = "table"
  algorithm = "leastconn"
  cipher_suite = "recommended"
  ssl_key = var.ssl_key
  ssl_cert = var.ssl_cert
}

resource "linode_nodebalancer_node" "prod_2019_10_https" {
  label = "prod_2019_10_https"
  address = "${linode_instance.prod_2019_10.private_ip_address}:80"
  mode = "accept"
  nodebalancer_id = linode_nodebalancer.prod_2019_10.id
  config_id = linode_nodebalancer_config.prod_2019_10_https.id
}

resource "dnsimple_record" "changelog_com_ipv4_201910" {
  domain = "changelog.com"
  name = "201910"
  value = linode_nodebalancer.prod_2019_10.ipv4
  type = "A"
  ttl = 60
}

resource "dnsimple_record" "changelog_com_ipv6_201910" {
  domain = "changelog.com"
  name = "201910"
  value = linode_nodebalancer.prod_2019_10.ipv6
  type = "AAAA"
  ttl = 60
}

resource "dnsimple_record" "changelog_com_ipv4_201910i" {
  domain = "changelog.com"
  name = "201910i"
  value = linode_instance.prod_2019_10.ip_address
  type = "A"
  ttl = 60
}
