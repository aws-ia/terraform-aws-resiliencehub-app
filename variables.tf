variable "source_arns" {
  type        = list(string)
  description = "list of ARNs of AWS Resource Groups or AWS CloudFormation Stacks"
}

variable "rto" {
  type        = number
  description = "RTO across all failure metrics"
}

variable "rpo" {
  type        = number
  description = "RPO across all failure metrics"
}
