variable "project_id" {}
variable "region" {}
variable "bucket_name" {}
variable "kms_key_id" {
  description = "The full resource ID of the Cloud KMS key to use for bucket encryption"
  type        = string
}
