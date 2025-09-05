module "s3" {
  source = "../.."

  s3 = {
    bucket              = "my-example-bucket-kms-12345"
    force_destroy       = false
    object_lock_enabled = true
    acl                 = "private"
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
