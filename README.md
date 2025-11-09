# GCP Policy as Code Project

This repository demonstrates infrastructure policy enforcement for Google Cloud Platform (GCP) using:
- Terraform for infrastructure provisioning
- Open Policy Agent (OPA) for policy definition
- Conftest for policy testing
- GitHub Actions for automated policy checks

## Project Structure

```
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

## CI/CD Pipeline

This repository uses GitHub Actions for continuous integration and policy validation. The pipeline ensures that all infrastructure changes comply with security policies and best practices.

### Workflow Features

- **Automatic Triggers**: Runs on:
  - Pull requests to main branch
  - Push to main branch
  - Changes to `terraform/` or `opa_policies/` directories

- **Validation Steps**:
  1. Terraform format check
  2. Terraform code validation
  3. Infrastructure plan generation
  4. Policy compliance testing with Conftest
  5. Automated PR comments with results

### Setup Instructions

1. **Configure Workload Identity Federation in GCP**:
   ```bash
   # Enable required APIs
   gcloud services enable iamcredentials.googleapis.com
   gcloud services enable cloudresourcemanager.googleapis.com

   # Create Workload Identity Pool
   gcloud iam workload-identity-pools create "github-actions-pool" \
     --project="${PROJECT_ID}" \
     --location="global" \
     --display-name="GitHub Actions Pool"

   # Create Workload Identity Provider
   gcloud iam workload-identity-pools providers create-oidc "github-provider" \
     --project="${PROJECT_ID}" \
     --location="global" \
     --workload-identity-pool="github-actions-pool" \
     --display-name="GitHub provider" \
     --attribute-mapping="google.subject=assertion.sub,attribute.actor=assertion.actor,attribute.repository=assertion.repository" \
     --attribute-condition="attribute.repository=='<OWNER>/<REPO>'" \
     --issuer-uri="https://token.actions.githubusercontent.com"

   # Create Service Account
   gcloud iam service-accounts create "github-actions-sa" \
     --project="${PROJECT_ID}" \
     --display-name="GitHub Actions service account"

   # Get the Workload Identity Provider resource name
   gcloud iam workload-identity-pools providers describe "github-provider" \
     --project="${PROJECT_ID}" \
     --location="global" \
     --workload-identity-pool="github-actions-pool" \
     --format="value(name)"
   ```

2. **Set up GitHub Repository Secrets**:
   
   Add these secrets in GitHub (Settings → Secrets and variables → Actions):
   - `WIF_PROVIDER`: Workload Identity Provider resource name
   - `WIF_SERVICE_ACCOUNT`: Service account email (github-actions-sa@PROJECT_ID.iam.gserviceaccount.com)
   - `GCP_PROJECT_ID`: Your GCP project ID
   - `GCP_SUBNET`: Your subnet path

3. **Grant IAM Permissions**:
   ```bash
   # Allow GitHub Actions to impersonate the service account
   gcloud iam service-accounts add-iam-policy-binding "github-actions-sa@${PROJECT_ID}.iam.gserviceaccount.com" \
     --project="${PROJECT_ID}" \
     --role="roles/iam.workloadIdentityUser" \
     --member="principalSet://iam.googleapis.com/projects/${PROJECT_NUMBER}/locations/global/workloadIdentityPools/github-actions-pool/attribute.repository/yadpriyanshu/gcp-pac-project"

   # Grant required permissions to the service account
   gcloud projects add-iam-policy-binding "${PROJECT_ID}" \
     --member="serviceAccount:github-actions-sa@${PROJECT_ID}.iam.gserviceaccount.com" \
     --role="roles/viewer"
   ```

### Workflow Operation

1. **Pull Request Creation/Update**:
   - Automated checks run on PR creation/update
   - Results posted as PR comments
   - Policy violations block PR merge

2. **Main Branch Push**:
   - Full validation suite runs
   - Results visible in Actions tab
   - Maintains main branch compliance

3. **Policy Violations**:
   - Detailed feedback in PR comments
   - Clear instructions for fixing issues
   - Links to policy documentation

## Contributing

1. Fork the repository
2. Create your feature branch
3. Commit your changes
4. Ensure all CI checks pass
5. Create a new Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.