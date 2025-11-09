output "instance_self_link" {
  value       = module.compute.instance_self_link
  description = "The self-link of the compute instance"
}

output "instance_service_account" {
  value       = module.compute.service_account_email
  description = "The service account email used by the instance"
}

output "instance_kms_key" {
  value       = module.compute.kms_key_id
  description = "The KMS key ID used for disk encryption"
}

output "instance_kms_keyring" {
  value       = module.compute.kms_keyring_id
  description = "The KMS keyring ID containing the disk encryption key"
}

output "bucket_url" {
  value       = module.storage.bucket_url
  description = "The URL of the created storage bucket"
}
