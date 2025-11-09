variable "project_id" {
  type = string
}

variable "region" {
  type    = string
  default = "us-central1"
}

variable "zone" {
  type    = string
  default = "us-central1-a"
}

variable "network" {
  type        = string
  default     = "custom-subnet" # not "default"
  description = "VPC network name or self_link (must not be 'default')"
}

variable "subnet" {
  type        = string
  description = "The subnet self link (format: projects/PROJECT_ID/regions/REGION/subnetworks/SUBNET_NAME)"
}

variable "instance_name" {
  type    = string
  default = "fbm-example"
}

variable "snapshot_schedule_name" {
  type    = string
  default = "snap-schedule-multi-region"
}

variable "ops_agent_startup_script" {
  type    = string
  default = <<-EOT
    #!/bin/bash
    # Install Ops Agent (example for linux)
    curl -sSO https://dl.google.com/cloudagents/add-google-cloud-ops-agent-repo.sh
    sudo bash add-google-cloud-ops-agent-repo.sh --also-install
  EOT
}

variable "bucket_kms_key" {
  description = "KMS key for the storage bucket"
  type        = string
  default     = ""
}