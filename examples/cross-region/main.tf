#####################################################################################
# Terraform module examples are meant to show an _example_ on how to use a module
# per use-case. The code below should not be copied directly but referenced in order
# to build your own root module that invokes this module
#####################################################################################
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.11"
    }
  }

  required_version = ">= 0.14.9"

  backend "s3" {
    bucket = "$BUCKET"
    key    = "$path/to/file.tfstate"
    region = "$BUCKET_REGION"
  }
}

locals {
  s3_state_file_url = "https://$BUCKET.s3.$BUCKET_REGION.amazonaws.com/$path/to/file.tfstate"
  app_name          = "Application-${random_string.session.id}"
}

resource "random_string" "session" {
  length  = 8
  special = false
}

module "use1" {
  source = "./use1"
}

module "use2" {
  source = "./use2"
}

module "resiliencehub_app" {
  app_name = local.app_name
  source   = "../.."
  rto      = 300
  rpo      = 60
  app_components = [
    {
      app_component_name = "CrossRegionAsgComponent"
      app_component_type = "AWS::ResilienceHub::ComputeAppComponent"
      resources = [
        {
          resource_name            = "Use1Asg"
          resource_type            = "AWS::AutoScaling::AutoScalingGroup"
          resource_identifier      = module.use1.asg_id
          resource_identifier_type = "Native"
          resource_region          = "us-east-1"
        },
        {
          resource_name            = "Use2Asg"
          resource_type            = "AWS::AutoScaling::AutoScalingGroup"
          resource_identifier      = module.use2.asg_id
          resource_identifier_type = "Native"
          resource_region          = "us-east-2"
        },
      ]
    },
  ]
  s3_state_file_url = local.s3_state_file_url
}
