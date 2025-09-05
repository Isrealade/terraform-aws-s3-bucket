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
* Object lock requires enabling `object_lock_enabled` **at bucket creation**; it cannot be changed later.