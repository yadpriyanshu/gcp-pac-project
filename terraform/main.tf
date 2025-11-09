module "compute" {
  source                   = "./modules/compute"
  project_id               = var.project_id
  region                   = var.region
  zone                     = var.zone
  network                  = var.network
  subnet                   = var.subnet
  instance_name            = var.instance_name
  ops_agent_startup_script = var.ops_agent_startup_script
  snapshot_schedule_name   = var.snapshot_schedule_name
}

module "storage" {
  source      = "./modules/storage"
  project_id  = var.project_id
  region      = var.region
  bucket_name = "${var.instance_name}-cloudzen-bucket"
  kms_key_id  = module.compute.kms_key_id
}
