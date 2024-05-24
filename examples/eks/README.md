<!-- BEGIN_TF_DOCS -->
# EKS-Integrated Resilience Hub Application


This Terraform configuration sets up an EKS-integrated Resilience Hub application. It incorporates an EKS cluster with an automated Fargate profile and key Kubernetes resources for application deployment, directly tied into AWS Resilience Hub to manage resilience policies effectively. The setup includes configuring specific IAM roles and Kubernetes ConfigMaps to ensure proper permissions alignment as per [AWS Resilience Hub documentation](https://docs.aws.amazon.com/resilience-hub/latest/userguide/grant-permissions-to-eks-in-arh.html).

**Note:** the `main.tf` file contains replacement strings that need to be adjusted before deployment:
- `$BUCKET`, the S3 bucket for Terraform state storage
- `$path/to/file.tfstate`, the file path for the state file within the bucket
- `$BUCKET_REGION`, the AWS region where the S3 bucket is located

## App Components Configuration

The `app_components` configuration outlines how each part of the application is deployed and managed as a resilient component within AWS Resilience Hub:

```hcl
app_components = [
  {
    app_component_name = "EksDeploymentComponent"
    app_component_type = "AWS::ResilienceHub::ComputeAppComponent"
    resources          = [
      {
        # Must be the deployment name
        resource_name            = "deployment-name"
        # One of AWS::EKS::Deployment, AWS::EKS::ReplicaSet, AWS::EKS::Pod
        resource_type            = "AWS::EKS::Deployment" 
        # Must be formatted as clusterArn/namespace/uid
        resource_identifier      = "${module.eks.cluster_arn}/${local.app_name}/${kubernetes_deployment_v1.this.metadata[0].uid}"
        resource_identifier_type = "Native"
        resource_region          = "us-west-2"
      }
    ]
  }
]
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 0.14.9 |
| aws | ~> 4.11 |
| kubernetes | n/a |
| helm | n/a |

## Providers

| Name | Version |
|------|---------|
| aws | ~> 4.11 |
| kubernetes | n/a |
| helm | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| eks | terraform-aws-modules/eks/aws | ~> 20.8 |
| eks_blueprints_addons | aws-ia/eks-blueprints-addons/aws | ~> 1.16 |
| vpc | terraform-aws-modules/vpc/aws | ~> 5.0 |

## Resources

| Name | Type |
|------|------|
| [aws_eks_cluster](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_cluster) | resource |
| [kubernetes_config_map_v1_data.aws_auth](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.20/#configmap-v1-core) | resource |
| [kubernetes_namespace_v1.this](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.20/#namespace-v1-core) | resource |
| [kubernetes_deployment_v1.this](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.20/#deployment-v1-apps) | resource |

## Inputs

No inputs.

## Outputs

No outputs.

## Additional Information

### IAM Roles and Kubernetes Permissions

Based on [AWS Resilience Hub's guidelines](https://docs.aws.amazon.com/resilience-hub/latest/userguide/grant-permissions-to-eks-in-arh.html), the configuration sets up IAM roles that allow the EKS cluster to interact with AWS services under defined permissions. These roles are pivotal for:
- Managing cluster resources via the AWS Management Console.
- Enabling automated deployment and management of applications using Kubernetes.

The `aws-auth` ConfigMap is crucial in linking AWS IAM roles with Kubernetes service accounts, enabling the EKS cluster to assign AWS permissions to pods efficiently.

### EKS Cluster Configuration

The EKS cluster setup includes:
- Public access to the Kubernetes API server.
- Integration with AWS VPC for network isolation and security.
- Fargate profiles to abstract server provisioning and scaling, enhancing the operational resilience of Kubernetes workloads.

The module also integrates EKS addons like CoreDNS, configured to run on Fargate, ensuring that DNS queries are efficiently handled within the cluster.

### Security and Compliance

All configurations follow AWS best practices for security and compliance, ensuring that data transit and at-rest are protected using AWS-managed encryption solutions. The setup also adheres to Kubernetes' RBAC policies to secure access to Kubernetes resources.

<!-- END_TF_DOCS -->
