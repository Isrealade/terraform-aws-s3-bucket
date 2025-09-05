variable "s3" {
  type = object({
    bucket              = string
    bucket_prefix       = optional(string)
    force_destroy       = bool
    object_lock_enabled = bool
    acl                 = string
    object_ownership    = string
  })

  default = {
    bucket              = ""
    force_destroy       = false
    acl                 = "private"
    object_lock_enabled = false
    object_ownership    = optional(string, "BucketOwnerPreferred")
  }

  description = <<-EOT
  Core S3 bucket configuration:
  - bucket: (Required) The name of the bucket. Must be globally unique.
  - bucket_prefix: (Optional) Creates a bucket name beginning with the specified prefix. Conflicts with "bucket".
  - force_destroy: (Optional, default = false) Delete all objects when bucket is destroyed.
  - object_lock_enabled: (Optional, default = false) Enable object lock. Must be set at creation time.
  - acl: (Required) Canned ACL to apply. Only "private" or "public-read" are supported in this module.
  - object_ownership: (Required) Ownership controls for uploaded objects.
      • AWS supports: "BucketOwnerPreferred", "ObjectWriter", "BucketOwnerEnforced".
      • This module only supports "BucketOwnerPreferred".
  EOT

  validation {
    condition     = contains(["private", "public-read"], var.s3.acl)
    error_message = "ACL must be either 'private' or 'public-read'."
  }

  validation {
    condition     = var.s3.object_ownership == "BucketOwnerPreferred"
    error_message = "This module only supports object_ownership = 'BucketOwnerPreferred'."
  }
}

variable "versioning" {
  type = object({
    enabled    = bool
    mfa_delete = optional(bool, false)
  })

  default = {
    enabled    = false
    mfa_delete = false
  }

  description = <<-EOT
  Bucket versioning configuration:
  - enabled: (Required) Set to true to enable versioning.
  - mfa_delete: (Optional, default = false) Require MFA for versioned object delete.
  EOT
}

variable "object_lock_configuration" {
  type = object({
    mode  = string
    days  = optional(number)
    years = optional(number)
  })

  default     = null
  description = <<-EOT
  Object lock default retention configuration:
  - mode: Retention mode ("GOVERNANCE" or "COMPLIANCE").
  - days: (Optional) Number of days to retain objects.
  - years: (Optional) Number of years to retain objects.
  Only one of "days" or "years" should be set.
  EOT

  validation {
    condition     = var.object_lock_configuration == null || contains(["GOVERNANCE", "COMPLIANCE"], try(var.object_lock_configuration.mode, ""))
    error_message = "object_lock_configuration.mode must be either 'GOVERNANCE' or 'COMPLIANCE'."
  }

}

variable "cors_rules" {
  type = list(object({
    allowed_headers = optional(list(string))
    allowed_methods = list(string)
    allowed_origins = list(string)
    expose_headers  = optional(list(string))
    max_age_seconds = optional(number)
  }))

  default     = []
  description = <<-EOT
  List of CORS rules to apply to the bucket.
  Each rule supports:
  - allowed_headers: (Optional) List of allowed headers, default ["*"].
  - allowed_methods: (Required) List of HTTP methods (e.g. ["GET", "POST"]).
  - allowed_origins: (Required) List of allowed origins (e.g. ["*"]).
  - expose_headers: (Optional) Headers exposed to the client.
  - max_age_seconds: (Optional) Cache duration for preflight requests.
  EOT
}

variable "encryption" {
  type = object({
    enabled           = bool
    sse_algorithm     = string
    kms_master_key_id = optional(string, null) # user can pass their own key
    create_kms_key    = optional(bool, false)  # whether module creates one
    key_rotation      = optional(bool, true)
    deletion_window   = optional(number, 7)
  })

  default = {
    enabled           = true
    sse_algorithm     = "AES256"
    kms_master_key_id = null
    create_kms_key    = false
  }

  description = <<-EOT
  Server-side encryption configuration:
  - enabled: (Required) Whether encryption is enabled (default true).
  - sse_algorithm: (Required) Encryption algorithm. "AES256" or "aws:kms".
  - kms_master_key_id: (Optional) ARN of an existing KMS key (required if using aws:kms and not creating a key).
  - create_kms_key: (Optional, default = false) Whether to create a new KMS key.
  - key_rotation: (Optional, default = true) Enable automatic KMS key rotation.
  - deletion_window: (Optional, default = 7) Waiting period (days) before KMS key is deleted.
  EOT

  validation {
    condition     = contains(["AES256", "aws:kms"], var.encryption.sse_algorithm)
    error_message = "sse_algorithm must be either 'AES256' or 'aws:kms'."
  }

  validation {
    condition     = !(var.encryption.sse_algorithm == "aws:kms" && var.encryption.kms_master_key_id == null && !var.encryption.create_kms_key)
    error_message = "When sse_algorithm is 'aws:kms', you must either set create_kms_key = true or provide a kms_master_key_id."
  }

  validation {
    condition     = !(var.encryption.sse_algorithm == "AES256" && (var.encryption.kms_master_key_id != null || var.encryption.create_kms_key))
    error_message = "When sse_algorithm is 'AES256', you cannot set kms_master_key_id or create_kms_key."
  }
}

variable "website" {
  type = object({
    enabled                  = bool
    index_document           = optional(string, "index.html")
    error_document           = optional(string, null)
    redirect_all_requests_to = optional(string, null) # e.g. "https://example.com"
    routing_rules            = optional(string, null) # JSON string if needed
  })

  default = {
    enabled                  = false
    index_document           = "index.html"
    error_document           = null
    redirect_all_requests_to = null
    routing_rules            = null
  }

  description = <<-EOT
  Static website hosting configuration:
  - enabled: (Required) Whether to enable website hosting.
  - index_document: (Optional, default = "index.html") Default index page.
  - error_document: (Optional) Error page key (e.g. "error.html").
  - redirect_all_requests_to: (Optional) Redirect all requests to another host.
  - routing_rules: (Optional) JSON string of advanced routing rules.
  EOT

  validation {
    condition     = !(var.website.enabled && var.website.index_document == null && var.website.redirect_all_requests_to == null)
    error_message = "When website.enabled is true, you must set either index_document or redirect_all_requests_to."
  }
}

variable "tags" {
  type    = map(string)
  default = {}

  description = <<-EOT
  A map of tags to assign to resources created by this module.
  The default is an empty map. You can provide key-value pairs
  (e.g. { "Environment" = "dev", "Project" = "my-app" }).
  EOT
}
