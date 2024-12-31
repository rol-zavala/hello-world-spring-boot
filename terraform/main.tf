# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 5.1"
    }
  }
}

# This is used to set local variable google_zone.
# This can be replaced with a statically-configured zone, if preferred.
data "google_compute_zones" "available" {
  region = "us-east1" # Cambia a la región adecuada
}

locals {
  google_zone = length(data.google_compute_zones.available.names) > 0 ? data.google_compute_zones.available.names[0] : "us-east1-b"
}

data "google_container_engine_versions" "supported" {
  provider = google-beta

  location       = local.google_zone
  version_prefix = var.kubernetes_version
}

resource "google_container_cluster" "default" {
  provider = google-beta

  name               = var.cluster_name
  location           = local.google_zone
  initial_node_count = var.workers_count
  min_master_version = data.google_container_engine_versions.supported.latest_master_version
  # node version must match master version
  # https://www.terraform.io/docs/providers/google/r/container_cluster.html#node_version
  node_version = data.google_container_engine_versions.supported.latest_master_version

  release_channel {
    channel = "RAPID"
  }


  node_config {
    machine_type = "e2-medium"
    disk_size_gb = 10
    oauth_scopes = [
      "https://www.googleapis.com/auth/compute",
      "https://www.googleapis.com/auth/devstorage.read_only",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]
  }

  identity_service_config {
    enabled = var.idp_enabled
  }

  deletion_protection = true

}
