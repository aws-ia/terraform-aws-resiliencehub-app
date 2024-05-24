variable "app_components" {
  type = list(object({
    app_component_name = string
    app_component_type = string
    resources          = list(object({
      resource_name            = string
      resource_type            = string
      resource_identifier      = string
      resource_identifier_type = string
      resource_region          = string
    }))
  }))

  description = "The application's app-components, including its resources"
}

variable "app_name" {
  type        = string
  description = "The Application's name"
}

variable "s3_state_file_url" {
  type        = string
  description = "An URL to s3-backend Terraform state-file"
}

variable "rto" {
  type        = number
  description = "RTO across all failure metrics"
}

variable "rpo" {
  type        = number
  description = "RPO across all failure metrics"
}

variable "arh_role_name" {
  type        = string
  description = "Defines the role to be used by Resilience Hub"
}