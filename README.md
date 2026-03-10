# Terraform-GitHub-Auto

> Beginner-friendly Terraform project to create and manage AWS EC2 instances via GitHub Actions.
> Uses **S3 backend** for state — Terraform automatically tracks what exists vs what you want.

---

## 📁 Project Structure

```
Terraform-GitHub-Auto/
├── main.tf                    ← Provider + S3 backend + module call
├── variables.tf               ← Variable declarations
├── terraform.tfvars.json      ← ✏️  Only file you need to edit
├── modules/
│   └── ec2/
│       ├── main.tf            ← EC2 resource
│       ├── variables.tf       ← Module inputs
│       └── outputs.tf         ← instance_id, public_ip, etc.
└── .github/
    └── workflows/
        └── terraform.yml      ← CI/CD pipeline (plan + apply)
```

---

## ⚙️ One-Time Setup (run once before first pipeline run)

```bash
# 1. Create S3 bucket for state storage (must be globally unique)
aws s3api create-bucket \
  --bucket terraform-state-bucket-prasamjain \
  --region us-east-1

# 2. Enable versioning (allows rollback if state gets corrupted)
aws s3api put-bucket-versioning \
  --bucket terraform-state-bucket-prasamjain \
  --versioning-configuration Status=Enabled

# 3. Create DynamoDB table for state locking
#    (prevents two pipeline runs from corrupting state simultaneously)
aws dynamodb create-table \
  --table-name terraform-state-lock \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST \
  --region us-east-1

# 4. Update bucket name in main.tf backend block to match step 1
```

Then add GitHub Secrets at **Repo → Settings → Secrets → Actions**:

| Secret | Value |
|---|---|
| `AWS_ACCESS_KEY_ID` | Your AWS access key |
| `AWS_SECRET_ACCESS_KEY` | Your AWS secret key |

---

## ✏️ How to Use

Just edit `terraform.tfvars.json` and push to main:

```json
{
  "aws_region":    "us-east-1",
  "ec2_name":      "my-first-ec2",
  "ami":           "ami-0c02fb55956c7d316",
  "instance_type": "t3.micro",
  "key_name":      "",
  "tags": {
    "Environment": "dev"
  }
}
```

---

## 🔄 How It Works — Current vs Desired State

```
Every pipeline run:

  terraform init
    └─ Downloads current tfstate from S3
       (this is what actually exists in AWS right now)

  terraform plan
    └─ Compares: S3 state (current) vs tfvars.json (desired)
       ┌─────────────────────────────────────────────────────┐
       │ Nothing changed?  → "No changes"  → apply skipped  │
       │ Something changed? → shows diff   → apply runs      │
       └─────────────────────────────────────────────────────┘

  terraform apply  (only if changes exist)
    └─ Updates AWS infra
    └─ Uploads new state to S3 automatically
```

| Scenario | Plan output | What happens |
|---|---|---|
| Re-run, nothing changed | `No changes` | Apply skipped, no new EC2 |
| Changed `instance_type` | `1 to change` | Existing EC2 updated in place |
| Changed `ec2_name` | `1 to change` | Name tag updated on existing EC2 |

---

## 🚀 Running Locally

```bash
export AWS_ACCESS_KEY_ID="..."
export AWS_SECRET_ACCESS_KEY="..."

terraform init                                  # connects to S3, downloads state
terraform plan -var-file=terraform.tfvars.json  # see what would change
terraform apply -var-file=terraform.tfvars.json # apply changes
```
