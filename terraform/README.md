# Terraform Environments

This directory provisions the AWS and cluster platform layer for AI BankApp.
Application workloads remain GitOps-managed from `k8s/`.

## Managed components

- VPC with public, private, and control-plane subnets
- EKS 1.35 with encrypted secrets, control-plane logs, managed node groups,
  VPC CNI network-policy enforcement, and EBS CSI plus Pod Identity add-ons
- ECR repository
- metrics-server
- Argo CD (private `ClusterIP`; HA in production)
- AWS Load Balancer Controller with a tightly scoped IRSA trust policy
- Envoy Gateway with Gateway API CRDs

Envoy Gateway creates the data-plane proxy, while the AWS Load Balancer
Controller reconciles its annotated `LoadBalancer` Service into an
internet-facing NLB with IP targets. `k8s/gateway.yml` routes public HTTP traffic
to BankApp through Gateway API resources. Public and private subnets carry the
AWS load-balancer discovery tags.

## Layout

```text
terraform/
  bootstrap/          # Remote-state S3 bucket and compatibility lock table
  live/
    dev/
    uat/
    prod/
  modules/
    vpc/
    compute/ecr/
    compute/eks/
    platform/argocd/
    platform/envoy-gateway/
    platform/metrics-server/
    platform/aws-load-balancer-controller/
```

## Environment profile

| Environment | Region | AZs | NAT | EKS API | Argo CD |
|---|---|---:|---|---|---|
| `dev` | `ap-south-1` | 2 | single | public + private | single replica |
| `uat` | `ap-south-1` | 2 | per-AZ | public + private | single replica |
| `prod` | `ap-south-1` | 3 | per-AZ | private only | HA + Redis HA |

Replace the dev/UAT `0.0.0.0/0` API CIDRs with exact office or VPN egress CIDRs
before applying. Production Terraform must run from a network that can reach the
private endpoint.

## Bootstrap remote state

Run once per AWS account:

```bash
cd terraform/bootstrap
terraform init
terraform plan -out=tfplan
terraform apply tfplan
```

The bootstrap stack creates an encrypted, versioned, public-access-blocked S3
bucket. Live roots use S3 native lock files via `use_lockfile = true`; the
DynamoDB table remains for compatibility with older Terraform clients.

Confirm the bucket names in `live/*/backend.tf` match the created bucket.

## Plan and apply

```bash
cd terraform/live/dev
terraform init
terraform fmt -check -recursive ../..
terraform validate
terraform plan -lock-timeout=5m -out=tfplan
terraform apply -lock-timeout=5m tfplan
```

Use the equivalent UAT or production root as needed. The machine running
Terraform needs AWS CLI v2 in `PATH` because the Kubernetes and Helm providers
use `aws eks get-token` for authentication.

The first apply creates EKS before installing Helm releases. On later AWS Load
Balancer Controller upgrades, apply the chart's latest CRDs before Terraform;
Helm installs CRDs but does not upgrade existing CRDs:

```bash
kubectl apply -f https://raw.githubusercontent.com/aws/eks-charts/master/stable/aws-load-balancer-controller/crds/crds.yaml
```

## Platform verification

```bash
aws eks update-kubeconfig --name ai-bankapp-dev --region ap-south-1
kubectl get nodes
kubectl get deployment -n kube-system aws-load-balancer-controller
kubectl get deployment -n kube-system metrics-server
kubectl get pods -n argocd
kubectl get pods -n envoy-gateway-system
kubectl get gateway,httproute -n bankapp
kubectl get ingressclass alb
```

Argo CD is not directly exposed. Use a local tunnel:

```bash
kubectl port-forward -n argocd svc/argocd-server 8443:443
```

## Gateway and TLS

`k8s/gateway.yml` initially exposes an HTTP listener for connectivity testing.
Do not transmit real credentials over that endpoint. Before production use,
configure an HTTPS listener with a certificate stored in a Kubernetes TLS
Secret and redirect HTTP to HTTPS.

The Envoy data-plane Service uses an internet-facing AWS NLB with IP targets.
The legacy `k8s/ingress.yml` remains excluded from the Argo CD Application so
that it does not create a second public load balancer.

## GitHub Actions

`.github/workflows/terraform.yml` supports pull-request validation and manual
plan/apply runs. It uses GitHub OIDC through `AWS_ROLE_TO_ASSUME`, saves the exact
plan as a short-lived artifact, and uses a self-hosted runner for private
production cluster access.

Configure a GitHub Environment for every deployable environment and require
reviewers for `prod`. The OIDC role should be scoped to this repository and the
minimum AWS actions required by the stack.

## Destroy order

Delete the Argo CD application and wait for its NLB to disappear before
destroying EKS. Otherwise, controller-owned load balancers and security groups
can remain and block VPC deletion.

```bash
kubectl delete -f argocd/application.yml
kubectl wait --for=delete gateway/bankapp -n bankapp --timeout=10m

cd terraform/live/dev
terraform plan -destroy -out=destroy.tfplan
terraform apply destroy.tfplan
```
