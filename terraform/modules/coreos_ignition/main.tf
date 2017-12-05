# Copyright (C) 2017 Kazumasa Kohtaka <kkohtaka@gmail.com> All right reserved
# This file is available under the MIT license.

variable "location" {}

resource "google_storage_bucket" "coreos_ignition" {
  name     = "coreos-ignition"
  location = "${var.location}"
}

resource "google_storage_bucket_acl" "coreos_ignition" {
  bucket      = "${google_storage_bucket.coreos_ignition.name}"
  default_acl = "publicread"
}

resource "google_storage_bucket_object" "iptables-nat-rules" {
  name   = "iptables-nat-rules"
  source = "modules/coreos_ignition/assets/iptables-nat-rules"
  bucket = "${google_storage_bucket.coreos_ignition.name}"
}
