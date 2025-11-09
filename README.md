# GCP Policy as Code Project

This repository demonstrates infrastructure policy enforcement for Google Cloud Platform (GCP) using:
- Terraform for infrastructure provisioning
- Open Policy Agent (OPA) for policy definition
- Conftest for policy testing
- GitHub Actions for automated policy checks

## Project Structure

```
├── conftest/          # Conftest configuration
├── opa_policies/      
│   ├── compute_policy.rego
│   └── storage_policy.rego
└── terraform/         
    ├── main.tf
    ├── variables.tf
    ├── outputs.tf
    └── modules/
        ├── compute/ 
        └── storage/ 
```

## Features

- **Infrastructure as Code**: Complete Terraform configuration for GCP resources
- **Policy as Code**: OPA policies for:
  - Compute Engine instance configurations
  - Cloud Storage bucket settings
- **Security Controls**:
  - Customer-managed encryption keys (CMEK)
  - Service account least privilege
  - Resource naming conventions
  - Required labels and tags

## Prerequisites

- Terraform >= 1.3
- Google Cloud SDK
- OPA/Conftest
- Access to a GCP project

## Usage

1. Initialize Terraform:
   ```bash
   cd terraform
   terraform init
   ```

2. Test policies against Terraform plan:
   ```bash
   terraform plan -out=tfplan
   terraform show -json tfplan > tfplan.json
   conftest test tfplan.json --policy ../opa_policies
   ```

3. Apply infrastructure:
   ```bash
   terraform apply
   ```

## Policy Testing

The repository includes comprehensive security and compliance policies:

### Google Compute Engine Policies

1. **Network Security**
   - No public IP addresses allowed
   - Default network usage is prohibited
   - VM access must be controlled through IAM permissions

2. **Location & Resource Standards**
   - Region restricted to us-central1 only
   - Machine type must be n2d-standard-8
   - VM names must start with "fbm-"

3. **Disk Configuration**
   - OS must be CentOS Stream 10
   - Boot disk: 100GB balanced persistent disk
   - Additional disk: 100GB balanced persistent disk
   - All disks must use Customer-Managed Encryption Keys (CMEK)

4. **Backup & Recovery**
   - Snapshot schedule must be present
   - Multi-region snapshot storage
   - 7-day default retention period

5. **Security & Monitoring**
   - Ops Agent must be installed for monitoring and logging
   - Compute Engine default service account prohibited
   - Deletion protection must be enabled

### Google Cloud Storage Policies

1. **Location & Naming**
   - Regional buckets only (us-central1)
   - Bucket names must contain "cloudzen"

2. **Storage Configuration**
   - Storage class must be Standard
   - Fine-grained access control required
   - Public access prevention enforced

3. **Data Protection**
   - CMEK encryption required
   - Soft delete policy enabled
   - 7-day retention period for soft-deleted objects

## Contributing

1. Fork the repository
2. Create your feature branch
3. Commit your changes
4. Push to the branch
5. Create a new Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.