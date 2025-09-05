module "s3_bucket" {
  source = "../../"

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
