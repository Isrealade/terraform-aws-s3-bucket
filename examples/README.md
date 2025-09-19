# Examples for `AWS S3 Bucket` Module

This directory contains usage examples for the **S3 Bucket module**.  
Each example demonstrates different configurations you can apply using the module.

---

## 📂 Available Examples

### 1. [basic](./basic)
Creates a simple S3 bucket with:
- Private ACL (default)
- Versioning disabled
- Encryption enabled with AES256 (default)
- No website or CORS configuration

```hcl
module "s3_basic" {
  source = "../../"

  s3 = {
    bucket              = "my-basic-example-bucket"
    force_destroy       = false
    object_lock_enabled = false
    acl                 = "private"
  }

  tags = {
    Environment = "dev"
    Example     = "basic"
  }
}
````

---

### 2. [private\_kms](./private_kms)

Creates a private S3 bucket with:

* Versioning enabled
* Encryption using a **KMS Key created by the module**
* Object Lock disabled

```hcl
module "s3_private_kms" {
  source = "../../"

  s3 = {
    bucket              = "my-private-kms-bucket"
    force_destroy       = false
    object_lock_enabled = false
    acl                 = "private"
  }

  versioning = {
    enabled    = true
    mfa_delete = false
  }

  encryption = {
    enabled         = true
    sse_algorithm   = "aws:kms"
    create_kms_key  = true
    key_rotation    = true
    deletion_window = 10
  }

  tags = {
    Environment = "staging"
    Example     = "private_kms"
  }
}
```

---

### 3. [cors\_versioned](./cors_versioned)

Creates a bucket configured for:

* Public-read ACL (for demo/static hosting only)
* Versioning enabled
* CORS rules (allowing GET/POST from any origin)
* Default AES256 encryption

```hcl
module "s3_cors_versioned" {
  source = "../../"

  s3 = {
    bucket              = "my-cors-versioned-bucket"
    force_destroy       = false
    object_lock_enabled = false
    acl                 = "public-read"
  }

  versioning = {
    enabled    = true
    mfa_delete = false
  }

  cors_rules = [
    {
      allowed_methods = ["GET", "POST"]
      allowed_origins = ["*"]
      allowed_headers = ["*"]
      expose_headers  = ["ETag"]
      max_age_seconds = 3000
    }
  ]

  tags = {
    Environment = "test"
    Example     = "cors_versioned"
  }
}
```

---

## 🚀 How to Use

Each example can be run independently.

```bash
terraform init
terraform plan
terraform apply
```

Replace `<example_name>` with one of:

* `basic`
* `private_kms`
* `cors_versioned`

---

## ⚠️ Notes & Limitations

* This module only supports **`private`** and **`public-read`** ACLs.
* Bucket **object ownership** is fixed to `BucketOwnerPreferred`.
* For production static websites, consider using **CloudFront with Origin Access Control (OAC)** instead of direct `public-read` buckets.
* You can override the default website policy by supplying the `bucket_policy` input as a JSON string. If omitted and you enable website hosting with `public-read` ACL, the module applies a default policy that allows `s3:GetObject` on all objects.

---

## 🧹 Cleanup

Don’t forget to destroy resources when done testing:

```bash
terraform destroy
```