output "instance_self_link" {
  value       = google_compute_instance.vm.self_link
  description = "The self-link of the compute instance"
}

output "service_account_email" {
  value       = google_service_account.instance_sa.email
  description = "The email of the service account created for the instance"
}

output "kms_key_id" {
  value       = google_kms_crypto_key.crypto_key.id
  description = "The ID of the KMS key used for disk encryption"
}

output "kms_keyring_id" {
  value       = google_kms_key_ring.key_ring.id
  description = "The ID of the KMS keyring"
}