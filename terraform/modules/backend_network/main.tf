# Copyright (C) 2017 Kazumasa Kohtaka <kkohtaka@gmail.com> All right reserved
# This file is available under the MIT license.

variable "name" {}
variable "subnetwork_name" {}

// Network

resource "google_compute_network" "primary" {
  name                    = "${var.name}"
  auto_create_subnetworks = "false"
}

// Subnetwork

resource "google_compute_subnetwork" "backend" {
  name          = "${var.subnetwork_name}"
  ip_cidr_range = "192.168.0.0/20"
  network       = "${google_compute_network.primary.self_link}"
}

// Firewalls

resource "google_compute_firewall" "backend-default" {
  name    = "fragile"
  network = "${google_compute_network.primary.name}"

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
}

resource "google_compute_firewall" "backend-internal" {
  name    = "backend-internal"
  network = "${google_compute_network.primary.name}"

  source_ranges = [
    // Allow connections between internal instances
    "${google_compute_subnetwork.backend.ip_cidr_range}",

    // Allow TCP connections from HTTP load balancers
    "130.211.0.0/22",

    "35.191.0.0/16",
  ]

  allow {
    protocol = "tcp"
    ports    = ["0-65535"]
  }

  allow {
    protocol = "udp"
    ports    = ["0-65535"]
  }
}

output "ipv4_range" {
  value = "${google_compute_subnetwork.backend.ip_cidr_range}"
}
