# Private S3 Bucket with KMS Encryption Example

This example demonstrates an S3 bucket using the `terraform-aws-s3-bucket` module with **server-side encryption using AWS KMS**, **versioning**, and **object lock enabled**.

## Features enabled

- Bucket ACL: `private`
- Bucket ownership: `BucketOwnerPreferred`
- Versioning enabled (MFA delete disabled)
- Object lock enabled with default retention (can be customized via variables)
- Server-side encryption using AWS KMS
- Website hosting disabled
- Force destroy disabled (objects must be deleted manually before destroying bucket)

## Usage

```hcl
module "s3_bucket_private_kms" {
  source = "../../"

  s3 = {
    bucket              = "my-example-bucket-kms-12345"
    force_destroy       = false
    object_lock_enabled = true
    acl                 = "private"
    object_ownership    = "BucketOwnerPreferred"
  }

  versioning = {
    enabled    = true
    mfa_delete = false
  }

  encryption = {
    enabled           = true
    sse_algorithm     = "aws:kms"
    create_kms_key    = true
    key_rotation      = true
    deletion_window   = 10
    kms_master_key_id = null
  }

  website = {
    enabled        = false
    index_document = null
    error_document = null
  }

  tags = {
    Environment = "prod"
    Project     = "kms-example"
  }
}

Notes

    Encryption uses a newly created KMS key with automatic key rotation enabled.

    Versioning ensures object history is preserved.

    Object lock is enabled; retention rules can be customized via object_lock_configuration.

    This example demonstrates a fully private bucket with enterprise-grade security features.