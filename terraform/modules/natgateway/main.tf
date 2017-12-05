# Copyright (C) 2017 Kazumasa Kohtaka <kkohtaka@gmail.com> All right reserved
# This file is available under the MIT license.

variable "count" {
  default = 1
}

variable "machine_type" {
  default = "f1-micro"
}

variable "region" {
  default = "asia-northeast1"
}

variable "network" {}
variable "subnetwork" {}
variable "zone" {}
variable "ip_cidr_range" {}

resource "google_compute_instance" "natgateway" {
  count        = "${var.count}"
  name         = "${format("natgateway%03d", count.index + 1)}"
  zone         = "${var.zone}"
  machine_type = "${var.machine_type}"

  can_ip_forward = true

  tags = ["group-natgateway"]

  boot_disk {
    initialize_params {
      image = "coreos-cloud/coreos-stable"
    }
  }

  network_interface {
    subnetwork = "${var.subnetwork}"

    access_config {
      // Ephemeral IP
    }
  }

  metadata {
    "os"     = "coreos"
    "system" = "natgateway"

    "block-project-ssh-keys" = "true"
    "ssh-keys"               = "core:${file("~/.ssh/id_rsa.pub")}"

    // TODO: Use templating on adding CoreOS Ignition file
    "user-data" = "${file("modules/natgateway/scripts/ignition.json")}"
  }
}

resource "google_compute_route" "no-external-ip" {
  name                   = "no-external-ip"
  dest_range             = "0.0.0.0/0"
  network                = "${var.network}"
  next_hop_instance      = "${google_compute_instance.natgateway.name}"
  next_hop_instance_zone = "${var.zone}"
  priority               = 800
  tags                   = ["no-external-ip"]
}

resource "google_compute_firewall" "no-external-ip" {
  name    = "no-external-ip"
  network = "${var.network}"

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["1-65535"]
  }

  allow {
    protocol = "udp"
    ports    = ["1-65535"]
  }

  source_ranges = ["${var.ip_cidr_range}"]
}
