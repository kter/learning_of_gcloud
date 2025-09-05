variable "project_id" {
  description = "The GCP project ID"
  type        = string
}

variable "region" {
  description = "The GCP region"
  type        = string
  default     = "asia-northeast1"
}

variable "zone" {
  description = "The GCP zone"
  type        = string
  default     = "asia-northeast1-a"
}

variable "instance_name" {
  description = "Name of the compute instance"
  type        = string
  default     = "terraform-instance"
}

variable "machine_type" {
  description = "Machine type for the instance"
  type        = string
  default     = "e2-micro"
}

variable "boot_disk_image" {
  description = "Boot disk image"
  type        = string
  default     = "debian-cloud/debian-11"
}

variable "boot_disk_size" {
  description = "Boot disk size in GB"
  type        = number
  default     = 10
}