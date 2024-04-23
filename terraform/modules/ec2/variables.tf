variable "resource_name_prefix" {
  type = string
}

variable "tags" {
  description = "Optional Tags"
  type        = map(string)
  default     = {}
}

variable "backend_system_subnet_id" {
  type = string
}

variable "backend_system_subnet_az" {
  type = string
}