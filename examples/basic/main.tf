module "s3" {
  source = "../.."

  s3 = {
    bucket              = "my-example-bucket-12345"
    acl                 = "public-read"
  }

  versioning = {
    enabled    = true
    mfa_delete = false
  }

  encryption = {
    enabled        = true
    sse_algorithm  = "AES256"
    create_kms_key = false
  }

  website = {
    enabled        = true
    index_document = "index.html"
    error_document = "error.html"
  }

  tags = {
    Environment = "test"
    Project     = "example"
  }
}
