# Terraform-GitHub-Auto

> Manage **multiple AWS resources** (EC2, S3, IAM, and more) from one pipeline.
> One tfstate in S3. One `terraform.tfvars.json` to control everything.

---

## 📁 Project Structure

```
Terraform-GitHub-Auto/
├── main.tf                    ← All module calls live here
├── variables.tf               ← Variable type declarations
├── terraform.tfvars.json      ← ✏️  Define ALL your resources here
├── modules/
│   ├── ec2/                   ← EC2 instance module
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   ├── s3/                    ← S3 bucket module
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   └── iam/                   ← IAM user module
│       ├── main.tf
│       ├── variables.tf
│       └── outputs.tf
└── .github/
    └── workflows/
        └── terraform.yml      ← CI/CD pipeline (unchanged)
```

---

## 🗂️ How One tfstate Tracks All Resources

```
S3: terraform-state-bucket-prasamjain
└── terraform/all-resources/terraform.tfstate
      │
      ├── module.ec2["web-server"].aws_instance.this       → i-0abc111
      ├── module.ec2["app-server"].aws_instance.this       → i-0abc222
      ├── module.s3["prasamjain-app-uploads"].aws_s3_bucket.this
      ├── module.s3["prasamjain-logs"].aws_s3_bucket.this
      ├── module.iam["dev-user"].aws_iam_user.this
      └── module.iam["ci-bot"].aws_iam_user.this
```

---

## ✏️ terraform.tfvars.json — Control Everything Here

```json
{
  "aws_region": "us-east-1",

  "ec2_instances": {
    "web-server": { "ami": "ami-xxx", "instance_type": "t3.micro", ... },
    "app-server": { "ami": "ami-xxx", "instance_type": "t3.small", ... }
  },

  "s3_buckets": {
    "my-app-uploads": { "versioning_enabled": true,  "force_destroy": false, ... },
    "my-logs":        { "versioning_enabled": false, "force_destroy": true,  ... }
  },

  "iam_users": {
    "dev-user": { "path": "/", "policy_arns": ["arn:aws:iam::aws:policy/ReadOnlyAccess"], ... },
    "ci-bot":   { "path": "/bots/", "policy_arns": ["arn:aws:iam::aws:policy/AmazonS3FullAccess"], ... }
  }
}
```

---

## 🔄 Behaviour for Every Resource Type

| Action in tfvars | What Terraform does | Other resources |
|---|---|---|
| Re-run, nothing changed | `No changes` | Untouched |
| Add a new key to any map | Creates only that new resource | Untouched |
| Remove a key from any map | Destroys only that resource | Untouched |
| Change a value (e.g. instance_type) | Updates only that resource | Untouched |

---

## ➕ How to Add a New Resource Type (e.g. RDS, SQS, VPC)

1. Create `modules/rds/main.tf`, `variables.tf`, `outputs.tf`
2. Add a `module "rds"` block in `main.tf` with `for_each`
3. Add a `variable "rds_instances"` block in `variables.tf`
4. Add `"rds_instances": { ... }` section in `terraform.tfvars.json`
5. Push to main → same pipeline runs, same S3 state tracks everything ✅

---

## ⚙️ One-Time Setup

```bash
# Create S3 bucket for state
aws s3api create-bucket --bucket terraform-state-bucket-prasamjain --region us-east-1
aws s3api put-bucket-versioning \
  --bucket terraform-state-bucket-prasamjain \
  --versioning-configuration Status=Enabled

# Create DynamoDB table for state locking
aws dynamodb create-table \
  --table-name terraform-state-lock \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST \
  --region us-east-1
```

GitHub Secrets at **Repo → Settings → Secrets → Actions**:

| Secret | Value |
|---|---|
| `AWS_ACCESS_KEY_ID` | Your AWS access key |
| `AWS_SECRET_ACCESS_KEY` | Your AWS secret key |

---

## 📊 Example Pipeline Output

```
ec2_instance_ids = {
  "app-server" = "i-0abc222"
  "web-server" = "i-0abc111"
}
s3_bucket_arns = {
  "prasamjain-app-uploads" = "arn:aws:s3:::prasamjain-app-uploads"
  "prasamjain-logs"        = "arn:aws:s3:::prasamjain-logs"
}
iam_user_arns = {
  "ci-bot"   = "arn:aws:iam::123456789:user/bots/ci-bot"
  "dev-user" = "arn:aws:iam::123456789:user/dev-user"
}
```
