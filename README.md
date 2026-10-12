
# Infrastructure Platform — Self-Service Storage & Identity Engine

Overview:
A production-grade, GitOps-driven Internal Developer Platform (IDP) enabling 300+ product teams to securely declare and provision AWS IAM workload identities and S3 buckets with automated security guardrails.

Architecture & Design:

1. GitOps Declarations vs. Custom UI/CLI
   *Zero Maintenance Overhead: Product teams utilize standardized Git PRs rather than custom platform UIs that accrue technical debt.
   *Audit Trail & Compliance: Every infrastructure change is recorded via version control with clear author attribution and PR review workflows.

2. Security Guardrails & Default Isolation
   *Explicit Public/Private Contract:** Silent defaults are eliminated—teams must explicitly state `public: true` or `public: false` for every bucket.
   *Least-Privilege Scope:** The platform factory generates IAM policies strictly granting access to the team's designated buckets.
   *Automated Encryption & Public Access Block:** Every S3 bucket enforces default server-side encryption (`AES256`) and dynamic `aws_s3_bucket_public_access_block` resource management.

3. Scalability Strategy (300 Teams)
*Modular Factory Pattern:** Root configurations consume declarations via `fileset()` and `jsondecode()`, leveraging dynamic `for_each` orchestration.

## Onboarding Guide for Product Teams

Product teams declare infrastructure needs by adding a JSON file to `declarations/`:

1. Create `declarations/team-<name>-<env>.json`:
   ```json
   {
     "team_name": "payments",
     "environment": "prod",
     "buckets": [
       { "name": "transactions", "public": false },
       { "name": "public-receipts", "public": true }
     ]
   }
