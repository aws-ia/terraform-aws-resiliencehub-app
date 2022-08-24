<!-- BEGIN_TF_DOCS -->
# Basic Example

Creates a cross-region multi-grouped Resilience Hub Application, with 2 EC2 Auto Scaling Groups in USE1 and USE2 - the module groups both \
Auto Scaling Groups in the same AppComponent.

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
| <a name="provider_random"></a> [random](#provider\_random) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_resiliencehub_app"></a> [resiliencehub\_app](#module\_resiliencehub\_app) | ../.. | n/a |
| <a name="module_use1"></a> [use1](#module\_use1) | ./use1 | n/a |
| <a name="module_use2"></a> [use2](#module\_use2) | ./use2 | n/a |

## Resources

| Name | Type |
|------|------|
| [random_string.session](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |

## Inputs

No inputs.

## Outputs

No outputs.
<!-- END_TF_DOCS -->