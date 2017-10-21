# Copyright (C) 2017 Kazumasa Kohtaka <kkohtaka@gmail.com> All right reserved
# This file is available under the MIT license.

variable "count" {
  default = 1
}

variable "machine_type" {
  default = "n1-highmem-2"
}

variable "zone" {
  default = "asia-northeast1"
}

variable "network" {
  default = "default"
}

resource "google_compute_instance" "prometheus" {
  count        = "${var.count}"
  name         = "${format("prometheus%03d", count.index + 1)}"
  machine_type = "${var.machine_type}"
  zone         = "${var.zone}"

  tags = []

  boot_disk {
    initialize_params {
      image = "coreos-cloud/coreos-stable"
    }
  }

  // Local SSD disk
  scratch_disk {}

  network_interface {
    network = "${var.network}"

    access_config {
      // Ephemeral IP
    }
  }

  metadata {
    system = "prometheus"
  }

  service_account {
    scopes = []
  }
}
