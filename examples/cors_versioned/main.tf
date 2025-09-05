module "s3" {
  source = "../.."

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
