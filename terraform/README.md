# Terraform Environments

This folder contains the production-style Terraform layout for AI BankApp.

## Layout

```text
terraform/
  bootstrap/          # Creates remote state bucket and lock resources
  live/
    dev/              # Development environment
    uat/              # UAT environment
    prod/             # Production environment
  modules/
    vpc/
    compute/ecr/
    compute/eks/
    platform/argocd/
    platform/metrics-server/
    platform/aws-load-balancer-controller/
```

## Environment Defaults

| Environment | Region | Cluster | AZs | NAT | Nodes | EKS API |
|---|---|---|---:|---|---|---|
| `dev` | `ap-south-1` | `ai-bankapp-dev` | 2 | single | small | public + private |
| `uat` | `ap-south-1` | `ai-bankapp-uat` | 2 | per-AZ | medium | public + private |
| `prod` | `ap-south-1` | `ai-bankapp-prod` | 3 | per-AZ | HA | private only |

Production uses immutable ECR image tags, VPC flow logs, EKS control plane logs, KMS secret encryption, private EKS API access, multi-AZ NAT, and larger node groups.

## Bootstrap Remote State

Run bootstrap once per AWS account:

```bash
cd terraform/bootstrap
terraform init
terraform apply
```

The bootstrap stack creates:

- S3 bucket for remote Terraform state
- S3 versioning and server-side encryption
- S3 public access block and bucket owner enforcement
- DynamoDB lock table kept for compatibility

The live environments use S3 native lock files through `use_lockfile = true`.

## Deploy an Environment

```bash
cd terraform/live/dev
terraform init
terraform plan
terraform apply
```

Use the matching folder for `uat` or `prod`.

## GitHub Actions

The `.github/workflows/terraform.yml` workflow supports:

- pull request checks for Terraform changes
- manual `plan` or `apply` through `workflow_dispatch`
- separate state files for `dev`, `uat`, and `prod`
- GitHub OIDC authentication through `AWS_ROLE_TO_ASSUME`
- production approval using the GitHub Environment named `prod`

To enforce manual production approval:

1. Go to GitHub repository settings.
2. Open `Environments`.
3. Create an environment named `prod`.
4. Add required reviewers.

When `environment=prod` and `action=apply` are selected, GitHub pauses the apply job until a reviewer approves it.

## Required GitHub Secret

| Secret | Purpose |
|---|---|
| `AWS_ROLE_TO_ASSUME` | IAM role ARN used by GitHub Actions OIDC |

## Notes

- Replace `cluster_endpoint_public_access_cidrs` in `dev` and `uat` with your office/VPN CIDRs before real use.
- The production EKS API endpoint is private-only, so the Terraform workflow sends `prod` jobs to a `self-hosted` runner. Place that runner on a network path that can reach the VPC, such as VPN, Direct Connect, or a private subnet runner.
