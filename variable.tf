variable "region" {
  type        = string
  description = "AWS Region"
}

variable "function_name" {
  type        = string
  description = "Function name"

}

variable "role_arn" {
  type        = string
  description = "Lambda IAM Role ARN"

}

variable "memory_size" {
  type        = number
  description = "Lambda memory size"

}