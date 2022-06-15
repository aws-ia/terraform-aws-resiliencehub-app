locals {
  num_sources = length(var.source_arns)
  rto         = var.rto
  rpo         = var.rpo
}

resource "awscc_resiliencehub_app" "app" {
  name              = "CoolApplication"
  app_template_body = local.num_sources >= 0 ? "" : "{}"
  resource_mappings = []
}

resource "awscc_resiliencehub_resiliency_policy" "policy" {
  policy_name = "CoolPolicy"
  tier        = "MissionCritical"
  policy = {
    az = {
      rto_in_secs = local.rto
      rpo_in_secs = local.rpo
    }
    hardware = {
      rto_in_secs = local.rto
      rpo_in_secs = local.rpo
    }
    software = {
      rto_in_secs = local.rto
      rpo_in_secs = local.rpo
    }
  }
}