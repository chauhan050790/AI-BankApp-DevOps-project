# Production Readiness

The repository has safe application defaults, deterministic database migrations,
shared sessions, blocking CI checks, hardened containers, health probes, disruption
protection, and internal-only metrics. Complete the environment-specific items below
before exposing an installation.

## Required configuration

The application intentionally has no default database username or password. Provide:

| Variable | Required production value |
|---|---|
| `MYSQL_HOST` | Database DNS name |
| `MYSQL_PORT` | Usually `3306` |
| `MYSQL_DATABASE` | Application database |
| `MYSQL_USER` | Dedicated, non-root application user |
| `MYSQL_PASSWORD` | Random secret from a secret manager |
| `MYSQL_SSL_MODE` | `REQUIRED` or `VERIFY_IDENTITY` with a trusted CA |
| `SESSION_COOKIE_SECURE` | `true` behind HTTPS |
| `OLLAMA_URL` | Internal Ollama endpoint |

Optional operational settings include `DB_POOL_MAX_SIZE`, `SESSION_TIMEOUT`,
`MAX_TRANSACTION_AMOUNT`, `BCRYPT_STRENGTH`, and the Ollama timeout variables.

For local development, copy `.env.example` to `.env`, replace both passwords, then
run `docker compose up --build`. MySQL and Ollama are not published to the host.

## Kubernetes secrets

`k8s/secrets.yml` was deliberately removed because base64 is not encryption. Create
the `bankapp-secret` before ArgoCD syncs the workloads. Use External Secrets Operator
with AWS Secrets Manager or Parameter Store for shared environments. The required keys
are documented in `k8s/bankapp-secret.yml.example`.

For an existing ArgoCD deployment, do not merge the manifest removal blindly: automated
pruning can delete the currently tracked Secret. Pause automatic sync, mark the live Secret
with `argocd.argoproj.io/sync-options=Prune=false`, establish the external-secret owner,
rotate the values, and only then sync this change. Verify the replacement Secret before
resuming automatic sync.

For an isolated development cluster only, create a local, gitignored env file and run:

```bash
kubectl apply -f k8s/namespace.yml
kubectl -n bankapp create secret generic bankapp-secret \
  --from-env-file=bankapp-secret.env \
  --dry-run=client -o yaml | kubectl apply -f -
```

Rotate the previously committed `Test@123` credential anywhere it was ever deployed.
Removing it from the current tree does not remove it from Git history or running clusters.

## Database rollout

Flyway owns the schema and Hibernate validates it at startup. A new database runs V1
and V2. An existing Hibernate-created database is baselined at V1 and then receives the
V2 shared-session tables. Back up the database before the first upgraded deployment and
test both migration and rollback procedures against a restored copy.

On an existing MySQL volume, the image entrypoint will not create `MYSQL_USER` again.
Create the dedicated application user and grant it access to `bankappdb` before replacing
the old root credentials. Because this deployment runs Flyway in the application process,
that user also needs the DDL permissions required by migrations.

For a real production system, use a managed Multi-AZ database such as Amazon RDS,
automated backups, point-in-time recovery, deletion protection, encryption with a managed
key, and alarms for storage, connections, replication, and backup failures. The included
single-pod MySQL manifest is appropriate for demos and non-critical environments, not a
high-availability banking datastore.

## Go-live checklist

- Upgrade from the older Spring Boot 3.4 line to an actively maintained release and run
  the full regression suite; this audit could not download the new dependency set.
- Replace `bankapp.trainwithshubham.com` in `k8s/ingress.yml` with an owned DNS name, validate a matching ACM certificate in the cluster region, and test the HTTP-to-HTTPS redirect.
- Pin MySQL, Ollama, BusyBox, and application images by immutable digest.
- Keep the application image tag immutable; deploy the commit-SHA tag, never `latest`.
- Confirm the CNI enforces `NetworkPolicy` and Prometheus discovers the `ServiceMonitor`.
- Run `./mvnw clean verify` and require both CI jobs before merge.
- Exercise registration, login, deposit, withdrawal, transfer, logout, and pod rollout.
- Test database restore, secret rotation, certificate renewal, and node disruption.
- Add WAF/rate limiting, centralized audit logs, alerting, retention, and incident runbooks.
- Run dependency, container, IaC, and dynamic security scans in the release pipeline.

## Scope warning

This is a demonstration banking application. Handling real funds additionally requires
an immutable double-entry ledger, idempotency keys, authorization policies, fraud and
AML controls, reconciliation, formal threat modeling, penetration testing, privacy and
retention controls, and the regulatory controls applicable to the deployment region.
