<!-- BEGIN_TF_DOCS -->
# AWS Resilience Hub Application

[AWS Resilience Hub](https://aws.amazon.com/blogs/aws/monitor-and-improve-your-application-resiliency-with-resilience-hub/) is a new AWS service designed to help you define, track, and manage the resilience of your applications. \
AWS Resilience Hub lets you define your RTO and RPO objectives for each of your applications. Then it assesses your application’s configuration to ensure it meets your requirements. It provides actionable recommendations and a resilience score to help you track your application’s resiliency progress over time.
This Terraform module contains AWS Resilience Hub resources.

The resources that make up the application tracked by [AWS Resilience Hub](https://aws.amazon.com/blogs/aws/monitor-and-improve-your-application-resiliency-with-resilience-hub) must be managed in a tfstate file that [exists in S3](https://www.terraform.io/language/settings/backends/s3). This is a requirement of the service. As such, the argument `s3_state_file_url` is required and must point to the tfstate file where the resources are managed.
If possible, our recommendation is to maintain your application deployment in the same [root module](https://www.terraform.io/docs/glossary#root-module) as the Resilience Hub app definition deployment. See our [basic example](https://github.com/aws-ia/terraform-aws-resiliencehub-app/tree/main/examples).

The `app-components` variable is an object list composed of the following schema:
```
list(object({
    app_component_name = string
    app_component_type = string
    resources = list(object({
      resource_name            = string
      resource_type            = string
      resource_identifier      = string
      resource_identifier_type = string
      resource_region          = string
    }))
  }))
```

A single app-component is composed of:
- `app_component_name` - a unique name for each app-component   
- `app_component_type` - one of the supported app-component types, as listed in https://docs.aws.amazon.com/resilience-hub/latest/userguide/AppComponent.grouping.html
- `resources` - the list of resources to that are assessed together

Please refer to https://docs.aws.amazon.com/resilience-hub/latest/userguide/AppComponent.grouping.html for more details.

A single resources is composed of:
- `resource_name` - a unique name for each resource
- `resource_type` - one of the supported resource types, as listed in https://docs.aws.amazon.com/resilience-hub/latest/userguide/AppComponent.grouping.html
- `resource_identifier` - either an ARN or identifier, depends on the actual resources (some AWS resources don't support ARN, refer to docs)
- `resource_identifier_type` - either `Native` or `Arn`, should correspond with `resource_identifier`
- `resource_region` - the AWS region where the resource is deployed

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.14.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 3.72.0 |
| <a name="requirement_awscc"></a> [awscc](#requirement\_awscc) | >= 0.21.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | ~> 3.5.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_awscc"></a> [awscc](#provider\_awscc) | >= 0.21.0 |
| <a name="provider_random"></a> [random](#provider\_random) | ~> 3.5.0 |

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
| <a name="input_app_components"></a> [app\_components](#input\_app\_components) | The application's app-components, including its resources | <pre>list(object({<br>    app_component_name = string<br>    app_component_type = string<br>    resources = list(object({<br>      resource_name            = string<br>      resource_type            = string<br>      resource_identifier      = string<br>      resource_identifier_type = string<br>      resource_region          = string<br>    }))<br>  }))</pre> | n/a | yes |
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