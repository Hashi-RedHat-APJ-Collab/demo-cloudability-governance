variable "role_name" {
  type        = string
  description = "The name of the role Cloudability will use"
  default     = "CloudabilityRole"
}

variable "bucket_name" {
  type        = string
  description = "The bucket where your cost files are kept"
  default     = "cloudabilityslynch"
}

variable "trusted_account_id" {
  type        = string
  description = "The Cloudability account this role will trust"
  default     = "165736516723"
}

variable "external_id" {
  type        = string
  description = "The external identifier to use, given to you by Cloudability"
  default     = "2884068b-fa40-4cec-aafd-a215e98532c2"
}

variable "user" {
  type        = string
  description = "User to be added to Trustee Relationship"
  default     = "cloudability"
}
