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

  default_labels = {
    "Managed by" = "Terraform"
    "Repository" = "learning_of_gcloud"
  }
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

// for_each式を使って複数構築
// 配列ではなく集合かマップである必要があるためtoset()を使用
module "compute-engine-list-for-each" {
  source = "./modules/compute-engine"
  for_each = toset(var.instance_name)
  name = each.value
  zone = "asia-northeast1-a"
  machine_type = "e2-micro"
}
// foreach式から出力(values())を使用
output "instance-lists-foreach" {
  value = values(module.compute-engine-list-for-each)[*].vm_public_ip
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

// apply前だと失敗するのでコメントアウト
// 従ってdataは別チーム管理、手動作成済みのもの、最新状態が必要なものに限った方が良い
// // dataから取得
// data "google_compute_instance" "vm_study" {
//   name = "gce-tokyo"
//   zone = "asia-northeast1-a"
// }
// output "vm_public_ip_from_data" {
//   value = data.google_compute_instance.vm_study.network_interface[0].access_config[0].nat_ip
// }
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

// dynamicブロックの例ここから
variable "additional_disks" {
  default = [
    {
      name = "disk1",
      size = 10,
      type = "pd-standard"
    },
    {
      name = "disk2",
      size = 10,
      type = "pd-standard"
    }
  ]
}

resource "google_compute_disk" "additional_disks" {
  for_each = { for disk in var.additional_disks : disk.name => disk }
  name = each.value.name
  size = each.value.size
  type = each.value.type
  zone = "asia-northeast1-a"
}

resource "google_compute_instance" "vm_study" {
  name = "gce-tokyo"
  zone = "asia-northeast1-a"
  machine_type = "e2-micro"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-12"
    }
  }

  dynamic "attached_disk" {
    for_each = google_compute_disk.additional_disks
    content {
      source = attached_disk.value.self_link
      mode = "READ_WRITE"
    }
  }

  network_interface {
    network = "default"
    access_config {}
  }
}
// dynamicブロックの例ここまで

// for式の例ここから
variable "instance_list" {
  type = list(string)
  default = ["gce-tokyo", "gce-tokyo-2"]
}
output "instance_list" {
  value = [for instance in var.instance_list : instance]
}
output "instance_list_with_upper" {
  value = [for instance in var.instance_list : upper(instance)]
}
output "instance_list_with_upper_and_length" {
  value = [for instance in var.instance_list : upper(instance) if length(instance) > 10]
}

variable "instance_map" {
  type = map(string)
  default = {
    "gce-tokyo" = "gce-tokyo-2"
    "gce-tokyo-2" = "gce-tokyo"
  }
}

output "instance_map" {
  value = { for key, value in var.instance_map : key => upper(value) }
}

output "instance_list_with_charactor_directive" {
  value = "%{for instance in var.instance_list } ${instance} %{endfor}"
}
// for式の例ここまで

// if statement using count example this here
variable "instance_create" {
  type = bool
  default = false
}
module "compute-engine-3" {
  count = var.instance_create ? 1 : 0
  source = "./modules/compute-engine"
  name = "gce-tokyo-3"
  zone = "asia-northeast1-a"
  machine_type = "e2-micro"
}
module "compute-engine-4" {
  count = var.instance_create ? 0 : 1
  source = "./modules/compute-engine"
  name = "gce-tokyo-4"
  zone = "asia-northeast1-a"
  machine_type = "e2-micro"
}
// if statement using count example this here

// if statement using for_each and for
variable "additional_disks_2" {
  default = [
    {
      name = "disk1",
      size = 10,
      type = "pd-standard"
    },
    {
      name = "disk2",
      size = 10,
      type = "pd-standard"
    }
  ]
}

resource "google_compute_disk" "additional_disks_2" {
  for_each = {
    for disk in var.additional_disks_2 : disk.name => disk
  }
  name = each.value.name
  size = each.value.size
  type = each.value.type
  zone = "asia-northeast1-a"
}
// if statement using for_each and for

// conditional branching using for_each and for example this here
variable "additional_disks_3" {
  default = [
    {
      name = "disk1",
      size = 10,
      type = "pd-standard"
    },
    {
      name = "disk2",
      size = 15,
      type = "pd-standard"
    }
  ]
}

resource "google_compute_disk" "additional_disks_3" {
  for_each = {
    for disk in var.additional_disks_3 : disk.name => disk if disk.size >= 15
  }
  name = each.value.name
  size = each.value.size
  type = each.value.type
  zone = "asia-northeast1-a"
}
// conditional branching using for_each and for example this here

// if directive example this here
variable "test_names" {
  default = [
    "test1",
    "test2",
    "test3"
  ]
}
output "test_names" {
  value = <<EOF
  %{~ for i, name in var.test_names ~}
  ${name}%{if i < length(var.test_names) - 1}, %{ else }. %{ endif }
  %{~ endfor ~}
  EOF
}
// if directive example this here

// example of validation
variable "instance_name_2" {
  type = string
  default = "gce-tokyo-3"
  // 基本的な入力のサニタイズ
  validation {
    condition = length(var.instance_name_2) > 0
    error_message = "instance_name_2 must be longer than 0"
  }
}
// example of varidate

//example of precondition and postcondition
variable "instance_name_3" {
  type = string
  default = "gce-tokyo-3"
}

resource "google_compute_disk" "vm_study_3_disk" {
  name = "vm-study-3-disk"
  size = 20
  type = "pd-standard"
  zone = "asia-northeast1-a"

  lifecycle {
    // 基本的な前提のチェック
    precondition {
      condition = var.instance_name_3 != null && length(var.instance_name_3) > 0
      error_message = "instance_name_3 must be provided and longer than 0 characters"
    }
    // 基本的な約束事を強制
    postcondition {
      condition = self.size > 0
      error_message = "vm_study_3_disk must have a size greater than 0"
    }
  }
}
//example of precondition and postcondition

resource "null_resource" "example" {

  triggers = {
    always_run = timestamp()
  }

  provisioner "local-exec" {
    command = "echo 'Hello, World!'"
  }
}

