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
    bucket = "yalevy-terraform-bucket"
    key    = "terraform/asg_multi_region.tf"
    region = "us-west-2"
  }
}

locals {
  s3_state_file_url = "https://yalevy-terraform-bucket.s3.us-west-2.amazonaws.com/terraform/asg_multi_region.tf"
  app_name          = "Application-${random_string.session.id}"
}

resource "random_string" "session" {
  length  = 8
  special = false
}

provider "aws" {
  region = "us-east-1"
  alias  = "use1"
}

provider "aws" {
  region = "us-east-2"
  alias  = "use2"
}

data "aws_ami" "ubuntu_use1" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-trusty-14.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners   = ["099720109477"] # Canonical
  provider = aws.use1
}

data "aws_ami" "ubuntu_use2" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-trusty-14.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners   = ["099720109477"] # Canonical
  provider = aws.use2
}

# tfsec:ignore:custom-custom-cus002 tfsec:ignore:aws-autoscaling-enforce-http-token-imds tfsec:ignore:aws-autoscaling-enable-at-rest-encryption tfsec:ignore:custom-custom-cus003
resource "aws_launch_configuration" "launch_conf_use1" {
  name_prefix   = "terraform-lc"
  image_id      = data.aws_ami.ubuntu_use1.id
  instance_type = "t2.micro"

  lifecycle {
    create_before_destroy = true
  }
  provider = aws.use1
}

# tfsec:ignore:custom-custom-cus002 tfsec:ignore:aws-autoscaling-enforce-http-token-imds tfsec:ignore:aws-autoscaling-enable-at-rest-encryption tfsec:ignore:custom-custom-cus003
resource "aws_launch_configuration" "launch_conf_use2" {
  name_prefix   = "terraform-lc"
  image_id      = data.aws_ami.ubuntu_use2.id
  instance_type = "t2.micro"

  lifecycle {
    create_before_destroy = true
  }
  provider   = aws.use2
  depends_on = [aws_launch_configuration.launch_conf_use1]
}

resource "aws_autoscaling_group" "autoscaling_group_use1" {
  name                 = "terraform-asg"
  availability_zones   = ["us-east-1a"]
  launch_configuration = aws_launch_configuration.launch_conf_use1.name
  min_size             = 1
  max_size             = 2

  lifecycle {
    create_before_destroy = true
  }
  provider   = aws.use1
  depends_on = [aws_launch_configuration.launch_conf_use2]
}

resource "aws_autoscaling_group" "autoscaling_group_use2" {
  name                 = "terraform-asg"
  availability_zones   = ["us-east-2a"]
  launch_configuration = aws_launch_configuration.launch_conf_use2.name
  min_size             = 1
  max_size             = 2

  lifecycle {
    create_before_destroy = true
  }
  provider   = aws.use2
  depends_on = [aws_autoscaling_group.autoscaling_group_use1]
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
          resource_identifier      = aws_autoscaling_group.autoscaling_group_use1.id
          resource_identifier_type = "Native"
          resource_region          = "us-east-1"
        },
        {
          resource_name            = "Use2Asg"
          resource_type            = "AWS::AutoScaling::AutoScalingGroup"
          resource_identifier      = aws_autoscaling_group.autoscaling_group_use2.id
          resource_identifier_type = "Native"
          resource_region          = "us-east-2"
        },
      ]
    },
  ]
  s3_state_file_url = local.s3_state_file_url
  depends_on        = [aws_autoscaling_group.autoscaling_group_use2]
}
