terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
      version = "~> 6.49.2"
    }
  }
  required_version = ">= 1.13.0"
}

provider "google" {
  project = var.project_id
  region = "asia-northeast1"
}


resource "google_compute_instance" "vm" {
  name         = "gce-tokyo"
  machine_type = "e2-micro"
  zone         = "asia-northeast1-a"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-12"
    }
  }

  network_interface {
    network = "default"
    access_config {}
  }
}


variable "project_id" {
  description = "GCP project ID to deploy resources into"
  type        = string
}

