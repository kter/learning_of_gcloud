output "instance_name" {
  description = "Name of the compute instance"
  value       = google_compute_instance.default.name
}

output "instance_internal_ip" {
  description = "Internal IP address of the instance"
  value       = google_compute_instance.default.network_interface[0].network_ip
}

output "instance_external_ip" {
  description = "External IP address of the instance"
  value       = google_compute_instance.default.network_interface[0].access_config[0].nat_ip
}

output "instance_id" {
  description = "Instance ID"
  value       = google_compute_instance.default.instance_id
}

output "instance_self_link" {
  description = "Self link of the instance"
  value       = google_compute_instance.default.self_link
}