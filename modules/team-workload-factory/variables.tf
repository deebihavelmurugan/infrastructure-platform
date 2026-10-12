variable "team_name" {
  type        = string
  description = "Name of the product team (e.g., alpha, payments)"
}

variable "environment" {
  type        = string
  description = "Target deployment environment (dev, staging, prod)"
}

variable "buckets" {
  type = list(object({
    name   = string
    public = bool
  }))
  description = "List of storage bucket declarations with explicit public/private visibility"
}
