<!-- BEGIN_TF_DOCS -->
# Basic Example

Creates a simple Resilience Hub Application, with a DynamoDB Table and RDS Instance - each in a single Resilience Hub AppComponent.

The module will be s3 state-file backed, as it is currently mandatory by Resilience Hub to onboard new terraform-Application using s3 only.\
**Note:** the `main.tf` file contains 3 replacement strings:
- `$BUCKET`, the bucket where we deploy the state file  
- `$path/to/file.tfstate"`, the exact path in `$BUCKET` where the state-file will be deployed in
- `$$BUCKET_REGION`, the region where the `$BUCKET` is deployed in

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.14.9 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 4.11 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 4.11 |
| <a name="provider_random"></a> [random](#provider\_random) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_resiliencehub_app"></a> [resiliencehub\_app](#module\_resiliencehub\_app) | ../.. | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_db_instance.rds_instance](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_instance) | resource |
| [aws_dynamodb_table.ddb_table](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/dynamodb_table) | resource |
| [random_string.session](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |

## Inputs

No inputs.

## Outputs

No outputs.
<!-- END_TF_DOCS -->