# Copyright (C) 2017 Kazumasa Kohtaka <kkohtaka@gmail.com> All right reserved
# This file is available under the MIT license.

variable "count" {
  default = 3
}

variable "machine_type" {
  default = "n1-highmem-2"
}

variable "zone" {
  default = "asia-northeast1"
}

variable "subnetwork" {
  default = "default"
}

resource "google_compute_instance_template" "influxdb" {
  name         = "influxdb"
  machine_type = "${var.machine_type}"

  tags = ["group-influxdb"]

  disk {
    source_image = "coreos-cloud/coreos-stable"
    boot         = true
    disk_size_gb = 60
  }

  network_interface {
    subnetwork = "${var.subnetwork}"

    access_config {
      // Ephemeral IP
    }
  }

  metadata {
    "os"     = "coreos"
    "system" = "influxdb"

    "block-project-ssh-keys" = "true"
    "ssh-keys"               = "core:${file("~/.ssh/id_rsa.pub")}"
  }
}

resource "google_compute_instance_group_manager" "influxdb" {
  name               = "influxdb"
  instance_template  = "${google_compute_instance_template.influxdb.self_link}"
  base_instance_name = "influxdb"
  zone               = "${var.zone}"
  target_size        = "${var.count}"

  named_port {
    name = "influxdb"
    port = 8086
  }
}

output "instance_count" {
  value = "${var.count}"
}
