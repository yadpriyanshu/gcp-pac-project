resource "google_storage_bucket" "bucket" {
  depends_on = [google_kms_crypto_key_iam_member.storage_service_agent]

  name          = var.bucket_name
  project       = var.project_id
  location      = var.region
  force_destroy = false

  uniform_bucket_level_access = false
  public_access_prevention    = "enforced"

  storage_class = "STANDARD"

  lifecycle_rule {
    condition {
      age = 7
    }
    action {
      type          = "SetStorageClass"
      storage_class = "STANDARD"
    }
  }

  soft_delete_policy {
    retention_duration_seconds = 604800 # 7 days
  }

  encryption {
    default_kms_key_name = var.kms_key_id
  }
}

# Get project number for service agent identity
data "google_project" "project" {
  project_id = var.project_id
}

# Grant Cloud Storage service agent permission to use the KMS key
resource "google_kms_crypto_key_iam_member" "storage_service_agent" {
  crypto_key_id = var.kms_key_id
  role          = "roles/cloudkms.cryptoKeyEncrypterDecrypter"
  member        = "serviceAccount:service-${data.google_project.project.number}@gs-project-accounts.iam.gserviceaccount.com"
}

output "bucket_url" {
  value = "gs://${google_storage_bucket.bucket.name}"
}
