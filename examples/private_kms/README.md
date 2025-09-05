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