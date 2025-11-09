package terraform.compute

import future.keywords.if
import future.keywords.in

# Helpers
vms := [r | some i; change := input.resource_changes[i]; change.type == "google_compute_instance"; change.change.actions[_] in ["create", "update"]; r := change]
disks := [r | some i; change := input.resource_changes[i]; change.type == "google_compute_disk"; change.change.actions[_] in ["create", "update"]; r := change]
snapshot_policies := [r | some i; change := input.resource_changes[i]; change.type == "google_compute_resource_policy"; change.change.actions[_] in ["create", "update"]; r := change]
disk_attachments := [r | some i; change := input.resource_changes[i]; change.type == "google_compute_disk_resource_policy_attachment"; change.change.actions[_] in ["create", "update"]; r := change]

# ALL RULES AS ARRAY deny[msg]
deny[msg] { vm := vms[i]; not vm.change.after.deletion_protection; msg := sprintf("VM '%s' must have deletion_protection=true", [vm.address]) }
deny[msg] { vm := vms[i]; not startswith(vm.change.after.zone, "us-central1-"); msg := sprintf("VM '%s' must be in us-central1", [vm.address]) }
deny[msg] { vm := vms[i]; vm.change.after.machine_type != "n2d-standard-8"; msg := sprintf("VM '%s' must be n2d-standard-8", [vm.address]) }
deny[msg] { d := disks[i]; contains(d.address, ".boot"); d.change.after.image != "centos-cloud/centos-stream-10"; msg := sprintf("Boot disk '%s' must use CentOS Stream 10", [d.address]) }
deny[msg] { d := disks[i]; contains(d.address, ".boot"); d.change.after.size != 100; msg := sprintf("Boot disk '%s' must be 100 GB", [d.address]) }
deny[msg] { d := disks[i]; contains(d.address, ".boot"); d.change.after.type != "pd-balanced"; msg := sprintf("Boot disk '%s' must be pd-balanced", [d.address]) }
deny[msg] { d := disks[i]; contains(d.address, ".additional_disk"); d.change.after.size != 100; msg := sprintf("Additional disk '%s' must be 100 GB", [d.address]) }
deny[msg] { d := disks[i]; contains(d.address, ".additional_disk"); d.change.after.type != "pd-balanced"; msg := sprintf("Additional disk '%s' must be pd-balanced", [d.address]) }
deny[msg] { count(snapshot_policies) == 0; msg := "Snapshot schedule missing" }
deny[msg] { p := snapshot_policies[i]; p.change.after.snapshot_schedule_policy[j].retention_policy[k].max_retention_days != 7; msg := "Snapshot retention must be 7 days" }
deny[msg] { p := snapshot_policies[i]; not "us" in p.change.after.snapshot_schedule_policy[j].snapshot_properties[k].storage_locations; msg := "Snapshot must use multi-region 'us'" }
deny[msg] { count(disk_attachments) == 0; msg := "Snapshot not attached to boot disk" }
deny[msg] { a := disk_attachments[i]; not contains(a.change.after.disk, "boot"); msg := "Snapshot attachment must reference boot disk" }
deny[msg] { vm := vms[i]; lower(vm.change.after.network_interface[j].network) == "default"; msg := sprintf("VM '%s' must not use default network", [vm.address]) }
deny[msg] { vm := vms[i]; not contains(vm.change.after.metadata_startup_script, "add-google-cloud-ops-agent-repo.sh"); msg := sprintf("VM '%s' must install Ops Agent", [vm.address]) }
deny[msg] { vm := vms[i]; contains(vm.change.after.service_account[j].email, "compute@developer.gserviceaccount.com"); msg := sprintf("VM '%s' must not use default Compute SA", [vm.address]) }
deny[msg] { d := disks[i]; count(d.change.after.disk_encryption_key) == 0; msg := sprintf("Disk '%s' must have CMEK block", [d.address]) }
deny[msg] { d := disks[i]; enc := d.change.after.disk_encryption_key[j]; enc.kms_key_self_link == null; msg := sprintf("Disk '%s' must reference a CMEK key", [d.address]) }
deny[msg] { vm := vms[i]; lower(object.get(vm.change.after.metadata, "enable-oslogin", "")) != "true"; msg := sprintf("VM '%s' must enable OS Login", [vm.address]) }
deny[msg] { vm := vms[i]; not startswith(vm.change.after.name, "fbm-"); msg := sprintf("VM '%s' name must start with fbm-", [vm.address]) }