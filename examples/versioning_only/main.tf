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
