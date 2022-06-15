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

## Providers

| Name | Version |
|------|---------|
| <a name="provider_awscc"></a> [awscc](#provider\_awscc) | >= 0.21.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [awscc_resiliencehub_app.app](https://registry.terraform.io/providers/hashicorp/awscc/latest/docs/resources/resiliencehub_app) | resource |
| [awscc_resiliencehub_resiliency_policy.policy](https://registry.terraform.io/providers/hashicorp/awscc/latest/docs/resources/resiliencehub_resiliency_policy) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_rpo"></a> [rpo](#input\_rpo) | RPO across all failure metrics | `number` | n/a | yes |
| <a name="input_rto"></a> [rto](#input\_rto) | RTO across all failure metrics | `number` | n/a | yes |
| <a name="input_source_arns"></a> [source\_arns](#input\_source\_arns) | list of ARNs of AWS Resource Groups or AWS CloudFormation Stacks | `list(string)` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_app_id"></a> [app\_id](#output\_app\_id) | The application created |
| <a name="output_policy_id"></a> [policy\_id](#output\_policy\_id) | The policy created |
<!-- END_TF_DOCS -->