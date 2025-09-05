module "s3" {
  source = "../.."

  s3 = {
    bucket              = "my-example-bucket-12345"
    force_destroy       = false
    object_lock_enabled = false
    acl                 = "private"
  }

  tags = {
    Environment = "dev"
    Project     = "demo"
  }
}
