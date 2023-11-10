variable "zone_id" {
  description = "The ID of the hosted zone to contain this record."
  type        = string
  default     = null
}

variable "name" {
  description = "The name of the record."
  type        = string
  default     = ""
}

variable "type" {
  description = "The record type. Valid values are A, AAAA, CAA, CNAME, DS, MX, NAPTR, NS, PTR, SOA, SPF, SRV and TXT."
  type        = string
  default     = null
}

variable "ttl" {
  description = "The TTL of the record."
  type        = number
  default     = null
}

variable "records" {
  description = " string list of records. To specify a single record value longer than 255 characters such as a TXT record for DKIM"
  type        = list(string)
  default     = null
}

variable "set_identifier" {
  description = "Unique identifier to differentiate records with routing policies from one another."
  type        = string
  default     = null
}

variable "health_check_id" {
  description = "The health check the record should be associated with."
  type        = string
  default     = null
}

variable "multivalue_answer_routing_policy" {
  description = "Set to true to indicate a multivalue answer routing policy."
  type        = bool
  default     = null
}

variable "allow_overwrite" {
  description = "Allow creation of this record in Terraform to overwrite an existing record, if any. This does not affect the ability to update the record in Terraform and does not prevent other resources within Terraform or manual Route 53 changes outside Terraform from overwriting this record. "
  type        = bool
  default     = false
}

variable "alias" {
  description = "An alias block. Conflicts with ttl & records"
  type        = map(any)
  default     = {}
}

variable "failover_routing_policy" {
  description = " block indicating the routing behavior when associated health check fails."
  type        = map(any)
  default     = {}
}

variable "latency_routing_policy" {
  description = "A block indicating a routing policy based on the latency between the requestor and an AWS region."
  type        = map(any)
  default     = {}
}

variable "weighted_routing_policy" {
  description = "A block indicating a weighted routing policy. Conflicts with any other routing policy."
  type        = map(any)
  default     = {}
}

variable "geolocation_routing_policy" {
  description = "A block indicating a routing policy based on the geolocation of the requestor."
  type        = map(any)
  default     = {}
}
