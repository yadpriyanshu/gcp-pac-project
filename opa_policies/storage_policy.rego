package terraform.storage

import future.keywords.if
import future.keywords.in

buckets := [r |
    some change in input.resource_changes
    change.type == "google_storage_bucket"
    change.change.actions[_] in ["create", "update"]
    r := change
]

# === 7 Storage Rules ===
deny[msg] if {
    r := buckets[_]
    lower(r.change.after.location) != "us-central1"
    msg := sprintf("Bucket '%s' must be in us-central1", [r.address])
}

deny[msg] if {
    r := buckets[_]
    not contains(lower(r.change.after.name), "cloudzen")
    msg := sprintf("Bucket '%s' name must contain 'cloudzen'", [r.address])
}

deny[msg] if {
    r := buckets[_]
    upper(r.change.after.storage_class) != "STANDARD"
    msg := sprintf("Bucket '%s' must use STANDARD class", [r.address])
}

deny[msg] if {
    r := buckets[_]
    lower(r.change.after.public_access_prevention) != "enforced"
    msg := sprintf("Bucket '%s' must enforce public access prevention", [r.address])
}

deny[msg] if {
    r := buckets[_]
    r.change.after.uniform_bucket_level_access != false
    msg := sprintf("Bucket '%s' must use fine-grained ACLs (uniform=false)", [r.address])
}

deny[msg] if {
    r := buckets[_]
    not r.change.after.soft_delete_policy
    msg := sprintf("Bucket '%s' must enable soft-delete", [r.address])
}
deny[msg] if {
    r := buckets[_]
    p := r.change.after.soft_delete_policy[_]
    p.retention_duration_seconds != 604800
    msg := sprintf("Bucket soft-delete must be 7 days", [r.address])
}

deny[msg] if {
    r := buckets[_]
    not r.change.after.encryption
    msg := sprintf("Bucket '%s' must have encryption block", [r.address])
}
deny[msg] if {
    r := buckets[_]
    enc := r.change.after.encryption[_]
    enc.default_kms_key_name == ""
    msg := sprintf("Bucket '%s' must specify a CMEK key", [r.address])
}