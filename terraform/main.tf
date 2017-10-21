# Copyright (C) 2017 Kazumasa Kohtaka <kkohtaka@gmail.com> All right reserved
# This file is available under the MIT license.

variable "project" {}
variable "region" {}

provider "google" {
  # Generate `account.json` by following the description in
  # https://www.terraform.io/docs/providers/google/index.html#authentication-json-file
  credentials = "${file("account.json")}"

  project = "${var.project}"
  region  = "${var.region}"
}

// Prometheus

module "prometheus" {
  source       = "./modules/prometheus"
  count        = 1
  machine_type = "n1-highmem-2"
  zone         = "${var.region}-a"
  network      = "default"
}
