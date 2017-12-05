# Copyright (C) 2017 Kazumasa Kohtaka <kkohtaka@gmail.com> All right reserved
# This file is available under the MIT license.

variable "count" {
  default = 1
}

variable "machine_type" {
  default = "g1-small"
}

variable "zone" {
  default = "asia-northeast1"
}

variable "subnetwork" {
  default = "default"
}

resource "google_compute_disk" "grafana" {
  name = "grafana"
  type = "pd-standard"
  zone = "${var.zone}"
  size = 1

  lifecycle {
    prevent_destroy = true
  }
}

resource "google_compute_instance_template" "grafana" {
  name         = "grafana"
  machine_type = "${var.machine_type}"

  tags = ["group-grafana"]

  disk {
    source_image = "coreos-cloud/coreos-stable"
    boot         = true
  }

  disk {
    device_name = "grafana"
    source = "${google_compute_disk.grafana.name}"
    type   = "PERSISTENT"

    auto_delete = false
  }

  network_interface {
    subnetwork = "${var.subnetwork}"

    access_config {
      // Ephemeral IP
    }
  }

  metadata {
    "os"     = "coreos"
    "system" = "grafana"

    "block-project-ssh-keys" = "true"
    "ssh-keys"               = "core:${file("~/.ssh/id_rsa.pub")}"
  }
}

resource "google_compute_instance_group_manager" "grafana" {
  name               = "grafana"
  instance_template  = "${google_compute_instance_template.grafana.self_link}"
  base_instance_name = "grafana"
  zone               = "${var.zone}"
  target_size        = "${var.count}"

  named_port {
    name = "grafana"
    port = 3000
  }
}

resource "google_compute_backend_service" "grafana" {
  name        = "grafana"
  port_name   = "grafana"
  protocol    = "HTTP"
  timeout_sec = 10

  backend {
    group = "${google_compute_instance_group_manager.grafana.instance_group}"
  }

  health_checks = ["${google_compute_health_check.grafana.self_link}"]
}

resource "google_compute_health_check" "grafana" {
  name = "grafana"

  timeout_sec        = 1
  check_interval_sec = 1

  http_health_check {
    port         = "3000"
    request_path = "/api/health"
  }
}

output "service_link" {
  value = "${google_compute_backend_service.grafana.self_link}"
}
