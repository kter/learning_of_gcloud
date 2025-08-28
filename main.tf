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

variable "project_id" {
  description = "GCP project ID to deploy resources into"
  type        = string
}

variable "instance_name" {
  type = list(string)
  default = ["gce-tokyo-list1", "gce-tokyo-list2"]
}

module "compute-engine" {
  source = "./modules/compute-engine"
  name = "gce-tokyo"
  zone = "asia-northeast1-a"
  machine_type = "e2-micro"
}

// count式を使って複数構築
module "compute-engine-list" {
  source = "./modules/compute-engine"
  name = var.instance_name[count.index]
  zone = "asia-northeast1-a"
  machine_type = "e2-micro"
  count = length(var.instance_name)
}


// スプラット式を使って全て表示
output "instance-lists" {
  value = module.compute-engine-list[*].vm_public_ip
}
module "compute-engine-2" {
  source = "github.com/kter/learning_of_gcloud_module//compute-engine?ref=v0.0.1"
  name = "gce-tokyo-2"
  zone = "asia-northeast1-a"
  machine_type = "e2-micro"
}

// dataから取得
data "google_compute_instance" "vm_study" {
  name = "gce-tokyo"
  zone = "asia-northeast1-a"
}
output "vm_public_ip_from_data" {
  value = data.google_compute_instance.vm_study.network_interface[0].access_config[0].nat_ip
}
// dataから取得ここまで

// moduleから取得
output "vm_public_ip_from_module" {
  value = module.compute-engine.vm_public_ip
}
// moduleから取得ここまで

// remote stateから取得
data "terraform_remote_state" "self" {
  backend = "gcs"
  config = {
    bucket = "learning-of-gcloud-tfstate"
    prefix = "terraform/state"
  }
}
output "vm_public_ip_from_remote_state" {
  value = try(data.terraform_remote_state.self.outputs.vm_public_ip, null)
}
// remote stateから取得ここまで