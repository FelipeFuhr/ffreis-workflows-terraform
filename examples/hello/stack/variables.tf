variable "name" {
  description = "Name to include in the greeting."
  type        = string
  default     = "world"

  validation {
    condition     = length(var.name) > 0
    error_message = "name must not be empty."
  }
}
