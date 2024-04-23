variable "region" {
  description = "AWS region"
  type        = string
  default     = "ap-southeast-1"
}

variable "prefix" {
  description = "Part of Resource naming prefix - prefix"
  type        = string
}

variable "tags" {
  description = "AWS resources tagging"
  type        = map(string)
}
