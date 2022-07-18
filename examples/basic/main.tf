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
    key    = "terraform/statefile.tf"
    region = "us-west-2"
  }
}

locals {
  s3_state_file_url = "https://yalevy-terraform-bucket.s3.us-west-2.amazonaws.com/terraform/statefile.tf"
  app_name          = "Application-${random_string.session.id}"
}

resource "random_string" "session" {
  length  = 8
  special = false
}

#tfsec:ignore:aws-dynamodb-enable-at-rest-encryption tfsec:ignore:aws-dynamodb-enable-recovery tfsec:ignore:aws-dynamodb-table-customer-key
resource "aws_dynamodb_table" "ddb_table" {
  billing_mode = "PAY_PER_REQUEST"
  name         = "DdbTable-${random_string.session.id}"

  hash_key = "key"
  attribute {
    name = "key"
    type = "N"
  }
}

#tfsec:ignore:aws-rds-encrypt-instance-storage-data tfsec:ignore:aws-rds-specify-backup-retention tfsec:ignore:aws-rds-enable-performance-insights
resource "aws_db_instance" "rds_instance" {
  allocated_storage    = 5
  engine               = "mysql"
  engine_version       = "5.7"
  instance_class       = "db.t3.micro"
  db_name              = "RDS${random_string.session.id}"
  username             = "foo"
  password             = "foobarbaz"
  parameter_group_name = "default.mysql5.7"
  skip_final_snapshot  = true
}

module "resiliencehub_app" {
  app_name = local.app_name
  source   = "../.."
  rto      = 300
  rpo      = 60
  app_components = [
    {
      app_component_name = "DynamoDBComponent"
      app_component_type = "AWS::ResilienceHub::DatabaseAppComponent"
      resources = [
        {
          resource_name            = "DynamoDBTable"
          resource_type            = "AWS::DynamoDB::Table"
          resource_identifier      = aws_dynamodb_table.ddb_table.id
          resource_identifier_type = "Native"
          resource_region          = "us-west-2"
        }
      ]
    },
    {
      app_component_name = "RdsComponent"
      app_component_type = "AWS::ResilienceHub::DatabaseAppComponent"
      resources = [
        {
          resource_name            = "RdsInstance"
          resource_type            = "AWS::RDS::DBInstance"
          resource_identifier      = aws_db_instance.rds_instance.id
          resource_identifier_type = "Native"
          resource_region          = "us-west-2"
        }
      ]
    }
  ]
  s3_state_file_url = local.s3_state_file_url
}
