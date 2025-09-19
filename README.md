# AWS S3 bucket Terraform module

This Terraform module to create and manage an **Amazon S3 bucket** with support for:

* Versioning
* Object Lock (optional)
* CORS configuration
* Server-Side Encryption (SSE-S3 or SSE-KMS)
* Website hosting configuration
* Ownership controls (`BucketOwnerPreferred`)
* Public access block settings

This module follows AWS best practices for S3 bucket provisioning while allowing flexibility for encryption, website hosting, and access control.

---

## 🚀 Features

* Create S3 bucket with optional prefix
* Enable/disable **force destroy**
* Enable/disable **object lock** and set retention rules
* Bucket **versioning** with optional MFA delete
* **CORS rules** support (dynamic)
* **Encryption**:

  * `AES256` (default)
  * `aws:kms` with option to use existing KMS key or create a new one
* **Website hosting**:

  * Supports index & error documents
  * Redirect all requests to another domain
  * Routing rules (JSON string)
* **Tagging** support for resources
* Optional custom **bucket policy** via input variable

---

## 📌 Limitations

* This module **only supports ACL values**:

  * `private`
  * `public-read`

* This module **only supports**:

  * `BucketOwnerPreferred` for `object_ownership`

* CloudFront integration is **not included in this version** (future enhancement).

* Website hosting requires the bucket ACL to allow **public read** (unless integrated with CloudFront + OAC/OAI).

---

## 🛠️ Usage

### Minimal Example

```hcl
module "s3_bucket" {
  source = "Isrealade/s3-bucket/aws"

  s3 = {
    bucket              = "my-unique-bucket-name"
    force_destroy       = false
    object_lock_enabled = false
    acl                 = "private"
  }

  tags = {
    Environment = "dev"
    Project     = "demo"
  }
}
```

### With Website Hosting

```hcl
module "s3_bucket" {
  source = "Isrealade/s3-bucket/aws"

  s3 = {
    bucket              = "my-website-bucket"
    force_destroy       = false
    object_lock_enabled = false
    acl                 = "public-read"
  }

  website = {
    enabled        = true
    index_document = "index.html"
    error_document = "error.html"
  }

  tags = {
    Environment = "prod"
    Project     = "static-site"
  }
}
```

### With Custom Bucket Policy

```hcl
module "s3_bucket" {
  source = "Isrealade/s3-bucket/aws"

  s3 = {
    bucket              = "my-site-bucket"
    force_destroy       = false
    object_lock_enabled = false
    acl                 = "public-read"
  }

  website = {
    enabled        = true
    index_document = "index.html"
  }

  # Provide a custom policy (JSON string). If omitted, a default
  # public-read website policy is applied when website is enabled
  # and ACL is public-read.
  bucket_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "AllowPublicRead"
        Effect    = "Allow"
        Principal = "*"
        Action    = ["s3:GetObject"]
        Resource  = ["${module.s3_bucket.bucket_arn}/*"]
      }
    ]
  })

  tags = {
    Environment = "prod"
  }
}
```

### With KMS Encryption

```hcl
module "s3_bucket" {
  source = "Isrealade/s3-bucket/aws"

  s3 = {
    bucket              = "secure-bucket"
    force_destroy       = false
    object_lock_enabled = false
    acl                 = "private"
  }

  encryption = {
    enabled        = true
    sse_algorithm  = "aws:kms"
    create_kms_key = true
  }

  tags = {
    Team = "security"
  }
}
```
### With cors versioned

```hcl
module "s3" {
  source = "Isrealade/s3-bucket/aws"

  s3 = {
    bucket              = "my-example-bucket-cors-12345"
    force_destroy       = true
    object_lock_enabled = false
    acl                 = "private"
  }

  versioning = {
    enabled    = true
    mfa_delete = false
  }

  cors_rules = [
    {
      allowed_headers = ["*"]
      allowed_methods = ["GET", "POST"]
      allowed_origins = ["https://example.com"]
      expose_headers  = ["ETag"]
      max_age_seconds = 3600
    }
  ]

  encryption = {
    enabled        = true
    sse_algorithm  = "AES256"
    create_kms_key = false
  }


  tags = {
    Environment = "dev"
    Project     = "cors-example"
  }
}

```
### With versioning only

```hcl
module "s3_bucket_versioning" {
  source = "Isrealade/s3-bucket/aws"

  s3 = {
    bucket              = "my-versioned-bucket"
    force_destroy       = false
    object_lock_enabled = false
    acl                 = "private"
    object_ownership    = "BucketOwnerPreferred"
  }

  versioning = {
    enabled    = true
    mfa_delete = false
  }

  # Object lock, encryption, CORS, and website are not enabled
  object_lock_configuration = null
  cors_rules                = []
  encryption                = {
    enabled        = false
    sse_algorithm  = "AES256"
  }
  website = {
    enabled = false
  }

  tags = {
    Environment = "dev"
    Project     = "versioning-only"
  }
}
```
### all features

```hcl
module "s3_bucket" {
  source = "Isrealade/s3-bucket/aws"

  s3 = {
    bucket              = "my-full-feature-bucket"
    bucket_prefix       = null
    force_destroy       = true
    object_lock_enabled = true
    acl                 = "private"
    object_ownership    = "BucketOwnerPreferred"
  }

  versioning = {
    enabled    = true
    mfa_delete = false
  }

  object_lock_configuration = {
    mode  = "COMPLIANCE"
    days  = 30
    years = null
  }

  cors_rules = [
    {
      allowed_headers = ["*"]
      allowed_methods = ["GET", "PUT"]
      allowed_origins = ["https://example.com"]
      expose_headers  = ["x-amz-server-side-encryption"]
      max_age_seconds = 3600
    }
  ]

  encryption = {
    enabled        = true
    sse_algorithm  = "aws:kms"
    create_kms_key = true
    key_rotation   = true
    deletion_window = 7
  }

  website = {
    enabled                  = true
    index_document           = "index.html"
    error_document           = "error.html"
    redirect_all_requests_to = null
    routing_rules            = null
  }

  tags = {
    Environment = "dev"
    Project     = "full-feature-s3"
  }
}
```
---

## 🔧 Inputs

| Name                        | Type         | Default                                                                                                                            | Description                                                                                                |
| --------------------------- | ------------ | ---------------------------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------- |
| `s3`                        | object       | `{ force_destroy = false, acl = "private", object_lock_enabled = false }`                                                          | Main bucket config. Supports `bucket`, `bucket_prefix`, `force_destroy`, `acl`, and `object_lock_enabled`. |
| `versioning`                | object       | `{ enabled = false, mfa_delete = false }`                                                                                          | Versioning config.                                                                                         |
| `object_lock_configuration` | object       | `null`                                                                                                                             | Object lock retention settings (`mode`, `days`, `years`).                                                  |
| `cors_rules`                | list(object) | `[]`                                                                                                                               | List of CORS rules.                                                                                        |
| `encryption`                | object       | `{ enabled = true, sse_algorithm = "AES256", kms_master_key_id = null, create_kms_key = false }`                                   | Server-side encryption config. Supports `AES256` and `aws:kms`.                                            |
| `website`                   | object       | `{ enabled = false, index_document = "index.html", error_document = null, redirect_all_requests_to = null, routing_rules = null }` | Website hosting config.                                                                                    |
| `bucket_policy`             | string       | `null`                                                                                                                             | Optional JSON policy string. When null, a default public-read website policy is used if website is enabled with ACL `public-read`. |
| `tags`                      | map(string)  | `{}`                                                                                                                               | Tags to apply to all resources.                                                                            |

---

## 📤 Outputs

| Name                          | Description                                           |
| ----------------------------- | ----------------------------------------------------- |
| `bucket_id`                   | The name of the bucket.                               |
| `bucket_arn`                  | The ARN of the bucket.                                |
| `bucket_domain_name`          | The bucket domain name (`<bucket>.s3.amazonaws.com`). |
| `bucket_regional_domain_name` | The bucket regional domain name.                      |
| `website_endpoint`            | The website endpoint (if hosting enabled).            |
| `website_domain`              | The website domain (if hosting enabled).              |
| `kms_key_arn`                 | ARN of KMS key (if created or supplied).              |
| `versioning_status`           | The versioning status of the bucket.                  |

---

## 🔮 Future Enhancements

* Optional support for **CloudFront distribution** with OAC/OAI for secure website hosting.
* Support for **directory buckets** (S3 Express One Zone).
* Integration with **lifecycle policies** (automatic object expiration, storage class transitions).

---

## 📝 Notes

* Ensure your bucket names are **globally unique**.
* If using `website.enabled = true`, remember that **content upload** is not handled by this module. Use `aws s3 sync` or a CI/CD pipeline for uploads.
* When `website.enabled = true` and ACL is `public-read`, the module will attach a default policy that allows `s3:GetObject` on all objects in the bucket unless you provide a custom `bucket_policy`.
* Object lock requires enabling `object_lock_enabled` **at bucket creation**; it cannot be changed later.