# CORS & Versioned S3 Bucket Example

This example demonstrates an S3 bucket using the `terraform-aws-s3-bucket` module with **CORS configuration** and **versioning enabled**.

## Features enabled

- Bucket ACL: `private`
- Bucket ownership: `BucketOwnerPreferred`
- Versioning enabled (MFA delete disabled)
- CORS rules configured
- Server-side encryption enabled (AES256)
- Minimal configuration for other features (object lock and website hosting are disabled)

## Usage

```hcl
module "s3_bucket_cors_versioned" {
  source = "../../"

  s3 = {
    bucket              = "my-example-bucket-cors-12345"
    force_destroy       = true
    object_lock_enabled = false
    acl                 = "private"
    object_ownership    = "BucketOwnerPreferred"
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

  website = { enabled = false }

  tags = {
    Environment = "dev"
    Project     = "cors-example"
  }
}

Notes

    CORS allows cross-origin requests from https://example.com with GET and POST methods.

    Versioning ensures object history is preserved in the bucket.

    Encryption is enabled using AES256.

    This example demonstrates core features for buckets requiring CORS and versioning without enabling object lock or website hosting.