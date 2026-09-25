# Deployment Playbook — AI BankApp on EKS

Terraform provisions the VPC, EKS cluster, ECR repository, EKS add-ons,
metrics-server, Argo CD, and AWS Load Balancer Controller. Argo CD then owns the
application manifests in `k8s/`.

## Prerequisites

- Terraform 1.15 or newer, but lower than 2.0
- AWS CLI v2 with credentials for the target account
- `kubectl`, Helm 3, and Docker
- An owned DNS name and a validated ACM certificate in `ap-south-1`
- GitHub repository variables/secrets required by the workflows

Do not expose this application with the included in-cluster MySQL database for
real banking workloads. See `PRODUCTION.md` for the remaining application and
data-layer requirements.

## 1. Bootstrap remote state

Run this once for the AWS account:

```bash
cd terraform/bootstrap
terraform init
terraform plan -out=tfplan
terraform apply tfplan
```

Confirm that every `terraform/live/*/backend.tf` bucket name matches the bucket
created by the bootstrap stack.

## 2. Prepare TLS and DNS

Replace `bankapp.trainwithshubham.com` in `k8s/ingress.yml` with your owned
hostname. Request an ACM public certificate in the same region as EKS and add
the ACM DNS-validation record at your DNS provider. Wait until the certificate
status is `ISSUED` before syncing the Ingress.

AWS Load Balancer Controller discovers the certificate from the Ingress host.
You can instead pin a certificate by adding this annotation:

```yaml
alb.ingress.kubernetes.io/certificate-arn: arn:aws:acm:REGION:ACCOUNT:certificate/ID
```

## 3. Provision an environment

Choose one of `dev`, `uat`, or `prod`:

```bash
cd terraform/live/dev
terraform init
terraform fmt -check -recursive ../..
terraform validate
terraform plan -lock-timeout=5m -out=tfplan
terraform apply -lock-timeout=5m tfplan
```

The production EKS API is private. Run production Terraform from a self-hosted
runner, VPN, Direct Connect connection, or host inside the VPC. Before applying
dev or UAT, replace `0.0.0.0/0` in
`cluster_endpoint_public_access_cidrs` with the exact office/VPN egress CIDRs.

If upgrading an existing AWS Load Balancer Controller release, apply the
current CRDs once before Terraform because Helm does not upgrade CRDs:

```bash
kubectl apply -f https://raw.githubusercontent.com/aws/eks-charts/master/stable/aws-load-balancer-controller/crds/crds.yaml
```

## 4. Configure and verify cluster access

```bash
aws eks update-kubeconfig --name ai-bankapp-dev --region ap-south-1
kubectl get nodes
kubectl get pods -n kube-system
kubectl get pods -n argocd
kubectl get ingressclass alb
```

Argo CD is intentionally a `ClusterIP` service. Access it locally:

```bash
kubectl port-forward -n argocd svc/argocd-server 8443:443
kubectl get secret argocd-initial-admin-secret -n argocd \
  -o jsonpath='{.data.password}' | base64 -d; echo
```

Open `https://localhost:8443` and rotate or disable the initial administrator
after configuring SSO and RBAC.

## 5. Create application secrets

Create `bankapp-secret` before Argo CD syncs the workloads. For a shared
environment, use External Secrets Operator with AWS Secrets Manager. For an
isolated development cluster only:

```bash
kubectl apply -f k8s/namespace.yml
kubectl -n bankapp create secret generic bankapp-secret \
  --from-env-file=bankapp-secret.env \
  --dry-run=client -o yaml | kubectl apply -f -
```

The required keys are documented in `k8s/bankapp-secret.yml.example`.

## 6. Deploy through Argo CD

The application definition tracks this repository's `main` branch:

```bash
kubectl apply -f argocd/application.yml
kubectl get application bankapp -n argocd -w
kubectl get pods -n bankapp
kubectl get ingress bankapp -n bankapp
```

When the Ingress reports an ALB hostname, create a DNS CNAME from the application
hostname to that ALB hostname:

```bash
kubectl get ingress bankapp -n bankapp \
  -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'; echo
```

Verify redirect, TLS, and application health:

```bash
curl -I http://bankapp.example.com
curl -I https://bankapp.example.com/login
kubectl get targetgroupbinding -n bankapp
```

## 7. Load the Ollama model

```bash
kubectl exec -n bankapp deploy/ollama -- ollama pull tinyllama
```

For production, build an Ollama image or use an initialization job that pins the
model artifact instead of performing this manually.

## Cleanup

Delete Kubernetes resources that own AWS load balancers before destroying EKS:

```bash
kubectl delete -f argocd/application.yml
kubectl wait --for=delete ingress/bankapp -n bankapp --timeout=10m

cd terraform/live/dev
terraform plan -destroy -out=destroy.tfplan
terraform apply destroy.tfplan
```

The Terraform module dependency graph removes Helm releases before EKS and the
VPC. Still verify in AWS that the ALB and its security groups have disappeared
before troubleshooting a VPC `DependencyViolation`.

## Common failures

- `Unauthorized` or Helm timeouts: the runner cannot reach the EKS endpoint or
  the AWS identity lacks an EKS access entry.
- AWS Load Balancer Controller `AccessDenied`: compare the deployed IAM policy
  with the controller version and confirm the service account role annotation.
- Ingress has no address: confirm the `alb` IngressClass, public subnet
  `kubernetes.io/role/elb=1` tags, controller logs, and issued ACM certificate.
- ALB targets are unhealthy: verify `/login` returns `200` on port `8080` and
  inspect the pod readiness probe on management port `8081`.
- Argo CD sync cannot find a `cert-manager.io` resource: remove the old
  Gateway/cert-manager manifests; this stack uses ACM TLS termination.
