output "bucket_id" {
  description = "The name of the bucket."
  value       = aws_s3_bucket.main.id
}

output "bucket_arn" {
  description = "The ARN of the bucket."
  value       = aws_s3_bucket.main.arn
}

output "bucket_domain_name" {
  description = "The bucket domain name. Will be of format <bucketname>.s3.amazonaws.com"
  value       = aws_s3_bucket.main.bucket_domain_name
}

output "bucket_regional_domain_name" {
  description = "The bucket region-specific domain name."
  value       = aws_s3_bucket.main.bucket_regional_domain_name
}

output "website_endpoint" {
  description = "The website endpoint (only set if website hosting is enabled)."
  value       = try(aws_s3_bucket_website_configuration.main[0].website_endpoint, null)
}

output "website_domain" {
  description = "The domain of the website endpoint (only if website hosting is enabled)."
  value       = try(aws_s3_bucket_website_configuration.main[0].website_domain, null)
}

output "kms_key_arn" {
  description = "The ARN of the KMS key used for encryption (if one was created or supplied)."
  value = (
    var.encryption.enabled && var.encryption.sse_algorithm == "aws:kms"
    ? (
      var.encryption.create_kms_key
      ? aws_kms_key.main[0].arn
      : var.encryption.kms_master_key_id
    )
    : null
  )
}

output "versioning_status" {
  description = "The versioning status of the bucket."
  value       = aws_s3_bucket_versioning.main.versioning_configuration[0].status
}
