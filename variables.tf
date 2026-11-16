variable "name" {
  type        = string
  nullable    = false
  description = "Name used for the web application's AWS resources"

  validation {
    condition     = length(trimspace(var.name)) > 0
    error_message = "Name must not be empty."
  }
}

variable "domain" {
  type        = string
  nullable    = false
  description = "Application domain name; the first label is removed to derive the Route53 zone"

  validation {
    condition     = can(regex("^[^.]+\\.[^.]+\\.[^.]+(?:\\.[^.]+)*$", var.domain))
    error_message = "Domain must contain at least three DNS labels."
  }
}

variable "dist_root" {
  type        = string
  nullable    = false
  description = "Root directory recursively searched for the application's index.html"

  validation {
    condition     = length(trimspace(var.dist_root)) > 0
    error_message = "Dist root must not be empty."
  }

  validation {
    condition     = try(length(fileset(var.dist_root, "**/index.html")) == 1, false)
    error_message = "Exactly one index.html must exist beneath dist_root."
  }
}

variable "bucket_name" {
  type        = string
  nullable    = false
  description = "Name of the S3 bucket that stores the application files"

  validation {
    condition     = length(trimspace(var.bucket_name)) > 0
    error_message = "Bucket name must not be empty."
  }
}

variable "manage_dns" {
  type        = bool
  default     = true
  nullable    = false
  description = "Look up the Route53 zone and create the application's alias record (default). Set to false when DNS is hosted elsewhere"
}

variable "certificate_arn" {
  type        = string
  default     = null
  description = "ARN of a us-east-1 ACM certificate for the distribution. Default looks up the issued wildcard certificate for the domain's parent"
}
