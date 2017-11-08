# Copyright (C) 2017 Kazumasa Kohtaka <kkohtaka@gmail.com> All right reserved
# This file is available under the MIT license.

variable "project" {}
variable "region" {}
variable "dns_name" {}

provider "google" {
  # Generate `account.json` by following the description in
  # https://www.terraform.io/docs/providers/google/index.html#authentication-json-file
  credentials = "${file("../account.json")}"

  project = "${var.project}"
  region  = "${var.region}"
}

// DNS Managed Zone

module "dns_zone" {
  source   = "./modules/dns_zone"
  dns_name = "${var.dns_name}"
}

// HTTP Proxy

module "http_loadbalancer" {
  source                  = "./modules/http_loadbalancer"
  dns_zone_name           = "${module.dns_zone.name}"
  dns_name                = "${module.dns_zone.dns_name}"
  default_service_link    = "${module.prometheus.service_link}"
  prometheus_service_link = "${module.prometheus.service_link}"
}

// Backend Network

module "backend_network" {
  source = "./modules/backend_network"
}

// Prometheus

module "prometheus" {
  source       = "./modules/prometheus"
  count        = 1
  machine_type = "n1-highmem-2"
  zone         = "${var.region}-a"
  network      = "${module.backend_network.link}"
}
