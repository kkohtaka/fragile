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

resource "google_compute_instance_template" "prometheus" {
  name         = "prometheus"
  machine_type = "${var.machine_type}"

  tags = ["group-prometheus"]

  disk {
    source_image = "coreos-cloud/coreos-stable"
    boot         = true
  }

  network_interface {
    network = "${var.network}"

    access_config {
      // Ephemeral IP
    }
  }

  metadata {
    "os"     = "coreos"
    "system" = "prometheus"

    "block-project-ssh-keys" = "true"
    "ssh-keys"               = "core:${file("~/.ssh/id_rsa.pub")}"
  }

  service_account {
    scopes = ["compute-ro"]
  }
}

resource "google_compute_instance_group_manager" "prometheus" {
  name               = "prometheus"
  instance_template  = "${google_compute_instance_template.prometheus.self_link}"
  base_instance_name = "prometheus"
  zone               = "${var.zone}"
  target_size        = "${var.count}"

  named_port {
    name = "prometheus"
    port = 9090
  }
}

resource "google_compute_backend_service" "prometheus" {
  name        = "prometheus"
  port_name   = "prometheus"
  protocol    = "HTTP"
  timeout_sec = 10

  backend {
    group = "${google_compute_instance_group_manager.prometheus.instance_group}"
  }

  health_checks = ["${google_compute_health_check.prometheus.self_link}"]
}

resource "google_compute_health_check" "prometheus" {
  name = "prometheus"

  timeout_sec        = 1
  check_interval_sec = 1

  http_health_check {
    port         = "9090"
    request_path = "/-/healthy"
  }
}

output "service_link" {
  value = "${google_compute_backend_service.prometheus.self_link}"
}
