variable "resource_name_prefix" {
  type = string
}

variable "tags" {
  description = "Optional Tags"
  type        = map(string)
  default     = {}
}

variable "map_public_ip_on_launch" {
  description = "Specify true to indicate that instances launched into the subnets should be assigned a public IP address"
  type        = bool
  default     = true
}

variable "instance_tenancy" {
  description = "A tenancy option for instances launched into the VPC."
  type        = string
  default     = "default"
}

variable "enable_dns_support" {
  description = "A boolean flag to enable/disable DNS support in the VPC. Default is true."
  type        = string
  default     = true
}

variable "enable_dns_hostnames" {
  description = "A boolean flag to enable/disable DNS hostnames in the VPC. Default is false."
  type        = string
  default     = false
}

variable "primary_zone_id" {
  description = "Primary Availability Zone"
  type        = string
}

variable "secondary_zone_id" {
  description = "Secondary Availability Zone"
  type        = string
}

variable "vpc_flow_logs_traffic_type" {
  description = "The type of traffic to capture."
  type        = string
  default     = "ALL"

  validation {
    condition     = contains(["ALL", "ACCEPT", "REJECT"], var.vpc_flow_logs_traffic_type)
    error_message = "Valid value is one of the following: ALL, ACCEPT, REJECT."
  }
}

variable "vpc_flow_logs_retention_in_days" {
  description = "Specifies the number of days you want to retain log events in the specified log group."
  type        = number
  default     = 14
}
