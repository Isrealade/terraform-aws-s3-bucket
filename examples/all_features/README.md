# All Features S3 Bucket Example

This example demonstrates a full-featured S3 bucket using the module `terraform-aws-s3-bucket`.

## Features enabled

- Bucket ACL: `private`
- Bucket ownership: `BucketOwnerPreferred`
- Versioning enabled
- Object Lock with COMPLIANCE mode
- Server-side encryption using AWS KMS
- CORS rules defined
- Static website hosting enabled
- Custom tags

## Usage

```hcl
module "s3_bucket" {
  source = "../../"

  s3 = {
    bucket              = "my-full-feature-bucket"
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
    enabled        = true
    index_document = "index.html"
    error_document = "error.html"
  }

  tags = {
    Environment = "dev"
    Project     = "full-feature-s3"
  }
}
