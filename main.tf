terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
      version = "~> 6.49.2"
    }
  }
  required_version = ">= 1.13.0"
  backend "gcs" {
    bucket = "learning-of-gcloud-tfstate"
    prefix = "terraform/state"
  }
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

output "vm_public_ip" {
  value = google_compute_instance.vm.network_interface[0].access_config[0].nat_ip
}

data "google_compute_instance" "vm" {
  name = "gce-tokyo"
  zone = resource.google_compute_instance.vm.zone
}

output "vm_public_ip_from_data" {
  value = data.google_compute_instance.vm.network_interface[0].access_config[0].nat_ip
}

data "terraform_remote_state" "default" {
  backend = "gcs"
  config = {
    bucket = "learning-of-gcloud-tfstate"
    prefix = "terraform/state"
  }
}

output "vm_public_ip_from_data_2" {
  value = data.terraform_remote_state.default.outputs.vm_public_ip
}