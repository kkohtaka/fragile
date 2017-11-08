# Copyright (C) 2017 Kazumasa Kohtaka <kkohtaka@gmail.com> All right reserved
# This file is available under the MIT license.

variable "dns_name" {}

resource "google_dns_managed_zone" "fragile" {
  name     = "fragile"
  dns_name = "${var.dns_name}"
}

output "name" {
  value = "${google_dns_managed_zone.fragile.name}"
}

output "dns_name" {
  value = "${google_dns_managed_zone.fragile.dns_name}"
}
