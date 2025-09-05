resource "aws_s3_bucket" "main" {
  bucket              = var.s3.bucket
  bucket_prefix       = var.s3.bucket_prefix
  force_destroy       = var.s3.force_destroy
  object_lock_enabled = var.s3.object_lock_enabled

  tags = var.tags
}

resource "aws_s3_bucket_cors_configuration" "main" {
  bucket = aws_s3_bucket.main.id
  count  = length(var.cors_rules) > 0 ? 1 : 0

  dynamic "cors_rule" {
    for_each = var.cors_rules
    content {
      allowed_headers = lookup(cors_rule.value, "allowed_headers", ["*"])
      allowed_methods = lookup(cors_rule.value, "allowed_methods", ["GET"])
      allowed_origins = lookup(cors_rule.value, "allowed_origins", ["*"])
      expose_headers  = lookup(cors_rule.value, "expose_headers", [])
      max_age_seconds = lookup(cors_rule.value, "max_age_seconds", 3000)
    }
  }
}

resource "aws_s3_bucket_ownership_controls" "main" {
  bucket = aws_s3_bucket.main.id
  rule {
    object_ownership = var.s3.object_ownership
  }
}

resource "aws_s3_bucket_public_access_block" "main" {
  bucket = aws_s3_bucket.main.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_acl" "main" {
  depends_on = [
    aws_s3_bucket_ownership_controls.main,
    aws_s3_bucket_public_access_block.main
  ]

  bucket = aws_s3_bucket.main.id
  acl    = var.s3.acl
}

resource "aws_s3_bucket_versioning" "main" {
  bucket = aws_s3_bucket.main.id

  versioning_configuration {
    status     = var.versioning.enabled ? "Enabled" : "Suspended"
    mfa_delete = var.versioning.mfa_delete ? "Enabled" : "Disabled"
  }
}

resource "aws_s3_bucket_object_lock_configuration" "main" {
  count  = var.s3.object_lock_enabled && var.object_lock_configuration != null ? 1 : 0
  bucket = aws_s3_bucket.main.id

  rule {
    default_retention {
      mode  = var.object_lock_configuration.mode
      days  = try(var.object_lock_configuration.days, null)
      years = try(var.object_lock_configuration.years, null)
    }
  }
}


resource "aws_kms_key" "main" {
  count                   = var.encryption.create_kms_key ? 1 : 0
  description             = "KMS key for S3 bucket encryption"
  deletion_window_in_days = var.encryption.deletion_window
  enable_key_rotation     = var.encryption.key_rotation
}

resource "aws_s3_bucket_server_side_encryption_configuration" "main" {
  count  = var.encryption.enabled ? 1 : 0
  bucket = aws_s3_bucket.main.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = var.encryption.sse_algorithm
      kms_master_key_id = var.encryption.sse_algorithm == "aws:kms" ? (
        var.encryption.create_kms_key ? aws_kms_key.main[0].arn : var.encryption.kms_master_key_id
      ) : null
    }
  }
}

resource "aws_s3_bucket_website_configuration" "main" {
  count  = var.website.enabled ? 1 : 0
  bucket = aws_s3_bucket.main.id

  dynamic "index_document" {
    for_each = var.website.index_document != null ? [1] : []
    content {
      suffix = var.website.index_document
    }
  }

  dynamic "error_document" {
    for_each = var.website.error_document != null ? [1] : []
    content {
      key = var.website.error_document
    }
  }

  dynamic "redirect_all_requests_to" {
    for_each = var.website.redirect_all_requests_to != null ? [1] : []
    content {
      host_name = var.website.redirect_all_requests_to
    }
  }

  routing_rules = var.website.routing_rules
}


