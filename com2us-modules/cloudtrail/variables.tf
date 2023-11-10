variable "name" {
  description = "(Required) Name of the trail."
  type        = string
  default     = null
}

variable "s3_bucket_name" {
  description = "(Required) Name of the S3 bucket designated for publishing log files."
  type        = string
  default     = null
}

variable "s3_key_prefix" {
  description = "(Optional) S3 key prefix that follows the name of the bucket you have designated for log file delivery."
  type        = string
  default     = ""
}

variable "is_multi_region_trail" {
  description = "(Optional) Whether the trail is created in the current region or in all regions. Defaults to false."
  type        = bool
  default     = false
}

variable "enable_log_file_validation" {
  description = "(Optional) Whether log file integrity validation is enabled. Defaults to false."
  type        = bool
  default     = false
}

variable "event_selector" {
  type = list(object({
    include_management_events = bool
    read_write_type           = string

    data_resource = list(object({
      type   = string
      values = list(string)
    }))
  }))

  description = "Specifies an event selector for enabling data event logging. See: https://www.terraform.io/docs/providers/aws/r/cloudtrail.html for details on this variable"
  default     = []
}
