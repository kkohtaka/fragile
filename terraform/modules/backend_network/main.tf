# Copyright (C) 2017 Kazumasa Kohtaka <kkohtaka@gmail.com> All right reserved
# This file is available under the MIT license.

resource "google_compute_network" "backend" {
  name = "backend"
}

resource "google_compute_firewall" "backend-default" {
  name    = "backend-default"
  network = "${google_compute_network.backend.name}"

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["22", "3389"]
  }
}

resource "google_compute_firewall" "backend-internal" {
  name    = "backend-internal"
  network = "${google_compute_network.backend.name}"

  // Allow connections between internal instances
  source_ranges = ["10.128.0.0/9"]

  allow {
    protocol = "tcp"
    ports    = ["0-65535"]
  }

  allow {
    protocol = "udp"
    ports    = ["0-65535"]
  }
}

resource "google_compute_firewall" "backend-web" {
  name    = "backend-web"
  network = "${google_compute_network.backend.name}"

  // Allow TCP connections from HTTP load balancers
  source_ranges = ["130.211.0.0/22", "35.191.0.0/16"]

  allow {
    protocol = "tcp"
    ports    = ["0-65535"]
  }

  allow {
    protocol = "udp"
    ports    = ["0-65535"]
  }
}

output "link" {
  value = "${google_compute_network.backend.self_link}"
}
