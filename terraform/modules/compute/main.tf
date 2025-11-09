# Data source to get project number for compute service agent identity
data "google_project" "project" {
  project_id = var.project_id
}

# Create KMS keyring
resource "google_kms_key_ring" "key_ring" {
  name     = "${var.instance_name}-keyring"
  location = var.region
  project  = var.project_id
}

# Create KMS key
resource "google_kms_crypto_key" "crypto_key" {
  name            = "${var.instance_name}-key"
  key_ring        = google_kms_key_ring.key_ring.id
  rotation_period = "7776000s" # 90 days

  lifecycle {
    prevent_destroy = true
  }
}

# Grant service account permission to use the key
resource "google_kms_crypto_key_iam_member" "crypto_key_user" {
  crypto_key_id = google_kms_crypto_key.crypto_key.id
  role          = "roles/cloudkms.cryptoKeyEncrypterDecrypter"
  member        = "serviceAccount:${google_service_account.instance_sa.email}"
}

# Grant compute service agent permission to use the key
resource "google_kms_crypto_key_iam_member" "compute_service_agent" {
  crypto_key_id = google_kms_crypto_key.crypto_key.id
  role          = "roles/cloudkms.cryptoKeyEncrypterDecrypter"
  member        = "serviceAccount:service-${data.google_project.project.number}@compute-system.iam.gserviceaccount.com"
}

# Create the additional disk
resource "google_compute_disk" "additional_disk" {
  name    = "${var.instance_name}-additional-disk"
  project = var.project_id
  zone    = var.zone
  size    = 100
  type    = "pd-balanced"
  disk_encryption_key {
    kms_key_self_link = google_kms_crypto_key.crypto_key.id
  }
}

resource "google_compute_resource_policy" "snapshot_schedule" {
  name    = var.snapshot_schedule_name
  project = var.project_id
  region  = var.region

  snapshot_schedule_policy {
    schedule {
      daily_schedule {
        days_in_cycle = 1
        start_time    = "00:00"
      }
    }

    retention_policy {
      max_retention_days    = 7
      on_source_disk_delete = "KEEP_AUTO_SNAPSHOTS"
    }

    snapshot_properties {
      storage_locations = ["us"]
    }
  }
}

# Create service account for the instance
resource "google_service_account" "instance_sa" {
  account_id   = "${var.instance_name}-sa"
  display_name = "Service Account for ${var.instance_name}"
  project      = var.project_id
}

# Grant compute admin role to the service account
resource "google_project_iam_member" "compute_admin" {
  project = var.project_id
  role    = "roles/compute.admin"
  member  = "serviceAccount:${google_service_account.instance_sa.email}"
}

# Attach snapshot policy to instance disks
resource "google_compute_disk" "boot" {
  name    = "${var.instance_name}-boot"
  project = var.project_id
  zone    = var.zone
  type    = "pd-balanced"
  image   = "centos-cloud/centos-stream-10"
  size    = 100

  disk_encryption_key {
    kms_key_self_link = google_kms_crypto_key.crypto_key.id
  }
}

resource "google_compute_disk_resource_policy_attachment" "boot_disk_attachment" {
  name    = google_compute_resource_policy.snapshot_schedule.name
  disk    = google_compute_disk.boot.name
  project = var.project_id
  zone    = var.zone
}

resource "google_compute_instance" "vm" {
  name         = var.instance_name
  project      = var.project_id
  zone         = var.zone
  machine_type = "n2d-standard-8"

  boot_disk {
    source            = google_compute_disk.boot.self_link
    kms_key_self_link = google_kms_crypto_key.crypto_key.id
  }

  attached_disk {
    source      = google_compute_disk.additional_disk.id
    device_name = "additional-disk"
  }


  network_interface {
    network    = var.network
    subnetwork = var.subnet
  }

  deletion_protection = true

  metadata = {
    "enable-oslogin" = "TRUE"
  }

  scheduling {
    automatic_restart   = true
    on_host_maintenance = "MIGRATE"
    preemptible         = false
  }


  service_account {
    email  = google_service_account.instance_sa.email
    scopes = ["https://www.googleapis.com/auth/cloud-platform"]
  }
  metadata_startup_script = var.ops_agent_startup_script
  tags                    = ["fbm"]
}