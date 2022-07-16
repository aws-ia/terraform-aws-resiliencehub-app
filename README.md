<!-- BEGIN_TF_DOCS -->
# AWS Resilience Hub Application

[AWS Resilience Hub](https://aws.amazon.com/blogs/aws/monitor-and-improve-your-application-resiliency-with-resilience-hub/) is a new AWS service designed to help you define, track, and manage the resilience of your applications. \
AWS Resilience Hub lets you define your RTO and RPO objectives for each of your applications. Then it assesses your application’s configuration to ensure it meets your requirements. It provides actionable recommendations and a resilience score to help you track your application’s resiliency progress over time.
This Terraform module contains AWS Resilience Hub resources.

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.14.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 3.72.0 |
| <a name="requirement_awscc"></a> [awscc](#requirement\_awscc) | >= 0.21.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | ~> 3.0.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_awscc"></a> [awscc](#provider\_awscc) | >= 0.21.0 |
| <a name="provider_random"></a> [random](#provider\_random) | ~> 3.0.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [awscc_resiliencehub_app.app](https://registry.terraform.io/providers/hashicorp/awscc/latest/docs/resources/resiliencehub_app) | resource |
| [awscc_resiliencehub_resiliency_policy.policy](https://registry.terraform.io/providers/hashicorp/awscc/latest/docs/resources/resiliencehub_resiliency_policy) | resource |
| [random_id.session](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/id) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_app_components"></a> [app\_components](#input\_app\_components) | The application's app-components, including its resources | <pre>list(object({<br>    app_component_name = string<br>    app_component_type = string<br>    resources = list(object({<br>      resource_name            = string<br>      resource_type            = string<br>      resource_identifier      = string<br>      resource_identifier_type = string<br>    }))<br>  }))</pre> | n/a | yes |
| <a name="input_app_name"></a> [app\_name](#input\_app\_name) | The Application's name | `string` | n/a | yes |
| <a name="input_rpo"></a> [rpo](#input\_rpo) | RPO across all failure metrics | `number` | n/a | yes |
| <a name="input_rto"></a> [rto](#input\_rto) | RTO across all failure metrics | `number` | n/a | yes |
| <a name="input_s3_state_file_url"></a> [s3\_state\_file\_url](#input\_s3\_state\_file\_url) | An URL to s3-backend Terraform state-file | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_app_id"></a> [app\_id](#output\_app\_id) | The application created |
| <a name="output_policy_id"></a> [policy\_id](#output\_policy\_id) | The policy created |
<!-- END_TF_DOCS -->