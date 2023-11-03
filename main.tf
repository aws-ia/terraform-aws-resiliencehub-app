locals {
  declared_app_components = [
    for app_component in var.app_components :
    {
      name = app_component["app_component_name"]
      type = app_component["app_component_type"]
      resourceNames = [
        for resource in app_component["resources"] :
        resource["resource_name"]
      ]
    }
  ]

  app_common_app_component = [
    {
      name = "appcommon"
      type = "AWS::ResilienceHub::AppCommonAppComponent",
      resourceNames : []
    }
  ]

  app_components = tolist(concat(local.declared_app_components, local.app_common_app_component))

  resources_list = flatten([
    for component in var.app_components : [
      for resource in component["resources"] : {
        resource_name            = resource["resource_name"]
        resource_type            = resource["resource_type"]
        resource_identifier_type = resource["resource_identifier_type"]
        resource_identifier      = resource["resource_identifier"]
        resource_region          = resource["resource_region"]
      }
    ]
  ])

  state_file_mapping = [
    {
      mapping_type = "Terraform"
      physical_resource_id = {
        identifier = var.s3_state_file_url
        type       = "Native"
      }
      terraform_source_name = "TerraformStateFile"
    }
  ]

  resources_mappings_only = [
    for resource in local.resources_list :
    {
      mapping_type = "Resource"
      physical_resource_id = {
        identifier = resource["resource_identifier"]
        type       = resource["resource_identifier_type"]
        aws_region = resource["resource_region"]
      }
      resource_name = resource["resource_name"]
    }
  ]

  resource_mappings = concat(local.resources_mappings_only, local.state_file_mapping)

  resources_json = [
    for resource in local.resources_list :
    {
      logicalResourceId = {
        identifier = resource["resource_name"]
      }
      type = resource["resource_type"]
      name = resource["resource_name"]
    }
  ]
}

resource "random_id" "session" {
  byte_length = 16
}

resource "awscc_resiliencehub_app" "app" {
  name = var.app_name
  app_template_body = jsonencode({
    resources         = local.resources_json
    appComponents     = local.app_components
    excludedResources = {}
    version           = 2
  })
  resource_mappings     = local.resource_mappings
  resiliency_policy_arn = awscc_resiliencehub_resiliency_policy.policy.policy_arn
  permission_model = {
    type                    = var.permission_type
    cross_account_role_arns = var.cross_account_role_arns
    invoker_role_name       = var.invoker_role_name
  }
}

resource "awscc_resiliencehub_resiliency_policy" "policy" {
  policy_name = "Policy-${random_id.session.id}"
  tier        = "MissionCritical"
  policy = {
    AZ = {
      rto_in_secs = var.rto
      rpo_in_secs = var.rpo
    }
    Hardware = {
      rto_in_secs = var.rto
      rpo_in_secs = var.rpo
    }
    Software = {
      rto_in_secs = var.rto
      rpo_in_secs = var.rpo
    }
    Region = {
      rto_in_secs = var.rto
      rpo_in_secs = var.rpo
    }
  }
}
