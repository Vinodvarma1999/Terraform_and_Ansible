variable "aws_region" {
  type        = string
  default     =  "us-east-1"
  description = "The AWS region to use for resources"
}

variable "ec2_num" {
  type    = number
  default = 2
}
