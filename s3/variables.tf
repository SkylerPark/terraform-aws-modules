variable "bucket" {
  description = "(Optional, Forces new resource) The name of the bucket. If omitted, Terraform will assign a random, unique name."
  type        = string
  default     = null
}

variable "bucket_prefix" {
  description = "(Optional, Forces new resource) Creates a unique bucket name beginning with the specified prefix. Conflicts with bucket."
  type        = string
  default     = null
}

variable "force_destroy" {
  description = "(Optional, Default:false ) A boolean that indicates all objects should be deleted from the bucket so that the bucket can be destroyed without error. These objects are not recoverable."
  type        = bool
  default     = false
}

variable "object_lock_enabled" {
  description = "Whether S3 bucket should have an Object Lock configuration enabled."
  type        = bool
  default     = false
}

variable "tags" {
  description = "(Optional) A mapping of tags to assign to the bucket."
  type        = map(string)
  default     = {}
}

variable "acl" {
  description = "(Optional) The canned ACL to apply. Conflicts with `grant`"
  type        = string
  default     = null
}

variable "grant" {
  description = "An ACL policy grant. Conflicts with `acl`"
  type        = any
  default     = []
}

variable "lifecycle_rule" {
  description = "List of maps containing configuration of object lifecycle management."
  type        = any
  default     = []
}

variable "logging" {
  description = "Map containing access bucket logging configuration."
  type        = map(string)
  default     = {}
}

variable "expected_bucket_owner" {
  description = "The account ID of the expected bucket owner"
  type        = string
  default     = null
}

variable "owner" {
  description = "Bucket owner's display name and ID. Conflicts with `acl`"
  type        = map(string)
  default     = {}
}

variable "attach_access_log_delivery_policy" {
  description = "Controls if S3 bucket should have S3 access log delivery policy attached"
  type        = bool
  default     = false
}

variable "attach_require_latest_tls_policy" {
  description = "Controls if S3 bucket should require the latest version of TLS"
  type        = bool
  default     = false
}

variable "attach_elb_log_delivery_policy" {
  description = "Controls if S3 bucket should have ELB log delivery policy attached"
  type        = bool
  default     = false
}

variable "attach_lb_log_delivery_policy" {
  description = "Controls if S3 bucket should have ALB/NLB log delivery policy attached"
  type        = bool
  default     = false
}

variable "attach_deny_insecure_transport_policy" {
  description = "Controls if S3 bucket should have deny non-SSL transport policy attached"
  type        = bool
  default     = false
}

variable "attach_inventory_destination_policy" {
  description = "Controls if S3 bucket should have bucket inventory destination policy attached."
  type        = bool
  default     = false
}

variable "attach_deny_incorrect_encryption_headers" {
  description = "Controls if S3 bucket should deny incorrect encryption headers policy attached."
  type        = bool
  default     = false
}

variable "attach_deny_unencrypted_object_uploads" {
  description = "Controls if S3 bucket should deny unencrypted object uploads policy attached."
  type        = bool
  default     = false
}

variable "attach_policy" {
  description = "Controls if S3 bucket should have bucket policy attached (set to `true` to use value of `policy` as bucket policy)"
  type        = bool
  default     = false
}

variable "attach_public_policy" {
  description = "Controls if a user defined public bucket policy will be attached (set to `false` to allow upstream to apply defaults to the bucket)"
  type        = bool
  default     = false
}

variable "block_public_acls" {
  description = "Whether Amazon S3 should block public ACLs for this bucket."
  type        = bool
  default     = true
}

variable "block_public_policy" {
  description = "Whether Amazon S3 should block public bucket policies for this bucket."
  type        = bool
  default     = true
}

variable "ignore_public_acls" {
  description = "Whether Amazon S3 should ignore public ACLs for this bucket."
  type        = bool
  default     = true
}

variable "restrict_public_buckets" {
  description = "Whether Amazon S3 should restrict public bucket policies for this bucket."
  type        = bool
  default     = true
}

variable "versioning" {
  description = "Map containing versioning configuration."
  type        = map(string)
  default     = {}
}
