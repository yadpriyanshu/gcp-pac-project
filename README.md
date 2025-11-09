# GCP Policy as Code Project

This repository demonstrates infrastructure policy enforcement for Google Cloud Platform (GCP) using:
- Terraform for infrastructure provisioning
- Open Policy Agent (OPA) for policy definition
- Conftest for policy testing
- GitHub Actions for automated policy checks

## Project Structure

```
├── conftest/          # Conftest configuration
├── opa_policies/      # OPA/Rego policy definitions
│   ├── compute_policies.rego
│   └── storage_policies.rego
└── terraform/         # Terraform configurations
    ├── main.tf
    ├── variables.tf
    ├── outputs.tf
    └── modules/
        ├── compute/  # GCP Compute Engine module
        └── storage/  # GCP Storage module
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

The repository includes policies for:
- Compute Engine instances
  - Required labels
  - Allowed machine types
  - Required disk encryption
- Storage buckets
  - Uniform bucket-level access
  - Required encryption
  - Lifecycle rules

## Contributing

1. Fork the repository
2. Create your feature branch
3. Commit your changes
4. Push to the branch
5. Create a new Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.