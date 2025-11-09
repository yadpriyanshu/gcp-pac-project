variable "project_id" {
  type        = string
  description = "The project ID where resources will be created"
}

variable "region" {
  type        = string
  description = "The region where resources will be created"
}

variable "zone" {
  type        = string
  description = "The zone where resources will be created"
}

variable "network" {
  type        = string
  description = "The VPC network name or self_link"
}

variable "subnet" {
  type        = string
  description = "The subnet self_link"
}

variable "instance_name" {
  type        = string
  description = "The name of the instance"
}

variable "ops_agent_startup_script" {
  type        = string
  description = "Startup script for installing ops agent"
}

variable "snapshot_schedule_name" {
  type        = string
  description = "Name of the snapshot schedule"
}
