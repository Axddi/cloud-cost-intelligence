variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "ap-south-1"
}

variable "alert_email" {
  description = "Email address to receive cost alerts"
  type        = string
}
