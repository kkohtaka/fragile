# Copyright (C) 2017 Kazumasa Kohtaka <kkohtaka@gmail.com> All right reserved
# This file is available under the MIT license.

variable "default_service_link" {}
variable "prometheus_service_link" {}

resource "google_compute_global_forwarding_rule" "fragile" {
  name       = "fragile"
  target     = "${google_compute_target_http_proxy.fragile.self_link}"
  port_range = "80"
}

resource "google_compute_target_http_proxy" "fragile" {
  name    = "fragile"
  url_map = "${google_compute_url_map.fragile.self_link}"
}

resource "google_compute_url_map" "fragile" {
  name = "fragile"

  default_service = "${var.default_service_link}"

  host_rule {
    hosts        = ["prometheus"]
    path_matcher = "prometheus"
  }

  path_matcher {
    name            = "prometheus"
    default_service = "${var.prometheus_service_link}"
  }
}
