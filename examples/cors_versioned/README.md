# CORS & Versioned S3 Bucket Example

This example demonstrates an S3 bucket using the `terraform-aws-s3-bucket` module with **CORS configuration** and **versioning enabled**.

## Features enabled

- Bucket ACL: `private`
- Bucket ownership: `BucketOwnerPreferred`
- Versioning enabled (MFA delete disabled)
- CORS rules configured
- Server-side encryption enabled (AES256)
- Minimal configuration for other features (object lock and website hosting are disabled)