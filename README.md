# Terraform-GitHub-Auto

> Beginner-friendly Terraform project to create AWS EC2 instances via GitHub Actions CI/CD.
> Uses **instance_id** (not Name tag) to uniquely track EC2s and prevent duplicates.

---

## 📁 Project Structure

```
Terraform-GitHub-Auto/
├── main.tf                    ← Root entry point (provider + module call)
├── variables.tf               ← Variable declarations
├── terraform.tfvars.json      ← ✏️  EDIT THIS to configure your EC2
├── modules/
│   └── ec2/
│       ├── main.tf            ← EC2 resource definition
│       ├── variables.tf       ← Module inputs
│       └── outputs.tf         ← Outputs: instance_id, public_ip, etc.
├── tfstates/                  ← (kept for reference, not used in pipeline)
└── .github/
    └── workflows/
        └── terraform.yml      ← CI/CD pipeline
```

---

## ✏️ How to Configure Your EC2

Edit `terraform.tfvars.json`:

```json
{
  "aws_region":    "us-east-1",
  "ec2_name":      "my-first-ec2",
  "ami":           "ami-0c02fb55956c7d316",
  "instance_type": "t3.micro",
  "key_name":      "",
  "instance_id":   "",
  "tags": {
    "Environment": "dev"
  }
}
```

> ⚠️ **Leave `instance_id` empty on first run.** The pipeline fills it in automatically after creating the EC2.

---

## 🔄 How Duplicate Prevention Works

**The problem:** AWS Name tags are NOT unique. Two EC2 instances can have the exact same `Name`. Terraform cannot use the Name tag to know an EC2 already exists — it needs the real unique AWS ID.

**The solution:** After every `apply`, the pipeline reads the real `instance_id` (e.g. `i-0abc1234`) from Terraform output and saves it to `terraform.tfvars.json`. On every re-run, the pipeline uses `terraform import` to tell Terraform "this EC2 already exists, here is its ID" — then `terraform plan` correctly shows **0 to add**.

| Scenario | What happens |
|---|---|
| **First run** (`instance_id` is empty) | EC2 is created, `instance_id` written to `tfvars.json` |
| **Re-run, nothing changed** | EC2 is imported into state → plan shows `No changes` |
| **Re-run, you changed `instance_type`** | EC2 is imported → plan shows `1 to change` → apply updates it in place |
| **You change `ec2_name` AND clear `instance_id`** | New EC2 is created with the new name |

---

## 🔑 Required GitHub Secrets

Go to: **Repo → Settings → Secrets and variables → Actions**

| Secret name | Value |
|---|---|
| `AWS_ACCESS_KEY_ID` | Your AWS access key |
| `AWS_SECRET_ACCESS_KEY` | Your AWS secret key |

---

## 🚀 Running Locally

```bash
# 1. Set AWS credentials
export AWS_ACCESS_KEY_ID="..."
export AWS_SECRET_ACCESS_KEY="..."

# 2. Init
terraform init

# 3. If EC2 already exists, import it first
terraform import -var-file=terraform.tfvars.json \
  module.ec2.aws_instance.this i-0abc1234567890

# 4. Plan (should show 0 changes if nothing changed)
terraform plan -var-file=terraform.tfvars.json

# 5. Apply
terraform apply -var-file=terraform.tfvars.json
```
