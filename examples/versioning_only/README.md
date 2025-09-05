# Versioning Only S3 Bucket Example

This example demonstrates an S3 bucket with **versioning enabled** using the `terraform-aws-s3-bucket` module.

## Features enabled

- Bucket ACL: `private`
- Bucket ownership: `BucketOwnerPreferred`
- Versioning enabled
- Minimal configuration (no encryption, object lock, CORS, or website hosting)

## Usage

```hcl
module "s3_bucket_versioning" {
  source = "../../"

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

  object_lock_configuration = null
  cors_rules                = []
  encryption = {
    enabled       = false
    sse_algorithm = "AES256"
  }
  website = {
    enabled = false
  }

  tags = {
    Environment = "dev"
    Project     = "versioning-only"
  }
}
