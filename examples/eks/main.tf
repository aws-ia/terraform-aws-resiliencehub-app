#####################################################################################
# Terraform module examples are meant to show an _example_ on how to use a module
# per use-case. The code below should not be copied directly but referenced in order
# to build your own root module that invokes this module
#####################################################################################

terraform {
  required_version = ">= 0.14.9"

  backend "s3" {
    bucket = "$BUCKET"
    key    = "$path/to/file.tfstate"
    region = "$BUCKET_REGION"
  }
}

# Taken from https://github.com/aws-ia/terraform-aws-eks-blueprints/blob/main/patterns/fargate-serverless/main.tf

provider "aws" {
  region = local.region
}

provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command = "aws"
    # This requires the awscli to be installed locally where Terraform is executed
    args        = ["eks", "get-token", "--cluster-name", module.eks.cluster_name]
  }
}

provider "helm" {
  kubernetes {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)

    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command = "aws"
      # This requires the awscli to be installed locally where Terraform is executed
      args        = ["eks", "get-token", "--cluster-name", module.eks.cluster_name]
    }
  }
}

data "aws_availability_zones" "available" {}
data "aws_caller_identity" "current" {}

locals {
  name     = basename(path.cwd)
  region   = "us-west-2"
  app_name = "app-2048"

  vpc_cidr = "10.0.0.0/16"
  azs      = slice(data.aws_availability_zones.available.names, 0, 3)

  tags = {
    Blueprint  = local.name
    GithubRepo = "github.com/aws-ia/terraform-aws-eks-blueprints"
  }
}

################################################################################
# Cluster
################################################################################

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.8"

  cluster_name                   = local.name
  cluster_version                = "1.29"
  cluster_endpoint_public_access = true

  # Give the Terraform identity admin access to the cluster
  # which will allow resources to be deployed into the cluster
  enable_cluster_creator_admin_permissions = true

  vpc_id = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  # Fargate profiles use the cluster primary security group so these are not utilized
  create_cluster_security_group = false
  create_node_security_group    = false

  fargate_profiles = {
    app_wildcard = {
      selectors = [
        { namespace = "app-*" }
      ]
    }
    kube_system = {
      name      = "kube-system"
      selectors = [
        { namespace = "kube-system" }
      ]
    }
  }

  fargate_profile_defaults = {
    iam_role_additional_policies = {
      additional = module.eks_blueprints_addons.fargate_fluentbit.iam_policy[0].arn
    }
  }

  tags = local.tags
}

################################################################################
# EKS Blueprints Addons
################################################################################

module "eks_blueprints_addons" {
  source  = "aws-ia/eks-blueprints-addons/aws"
  version = "~> 1.16"

  cluster_name     = module.eks.cluster_name
  cluster_endpoint = module.eks.cluster_endpoint
  cluster_version  = module.eks.cluster_version
  oidc_provider_arn = module.eks.oidc_provider_arn

  # We want to wait for the Fargate profiles to be deployed first
  create_delay_dependencies = [for prof in module.eks.fargate_profiles : prof.fargate_profile_arn]

  # EKS Add-ons
  eks_addons = {
    coredns = {
      configuration_values = jsonencode({
        computeType = "Fargate"
        # Ensure that the we fully utilize the minimum amount of resources that are supplied by
        # Fargate https://docs.aws.amazon.com/eks/latest/userguide/fargate-pod-configuration.html
        # Fargate adds 256 MB to each pod's memory reservation for the required Kubernetes
        # components (kubelet, kube-proxy, and containerd). Fargate rounds up to the following
        # compute configuration that most closely matches the sum of vCPU and memory requests in
        # order to ensure pods always have the resources that they need to run.
        resources = {
          limits = {
            cpu    = "0.25"
            # We are targeting the smallest Task size of 512Mb, so we subtract 256Mb from the
            # request/limit to ensure we can fit within that task
            memory = "256M"
          }
          requests = {
            cpu    = "0.25"
            # We are targeting the smallest Task size of 512Mb, so we subtract 256Mb from the
            # request/limit to ensure we can fit within that task
            memory = "256M"
          }
        }
      })
    }
    vpc-cni = {}
    kube-proxy = {}
  }

  # Enable Fargate logging
  enable_fargate_fluentbit = true
  fargate_fluentbit = {
    flb_log_cw = true
  }

  enable_aws_load_balancer_controller = true
  aws_load_balancer_controller = {
    set = [
      {
        name  = "vpcId"
        value = module.vpc.vpc_id
      },
      {
        name  = "podDisruptionBudget.maxUnavailable"
        value = 1
      },
    ]
  }

  tags = local.tags
}

################################################################################
# Supporting Resources
################################################################################

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = local.name
  cidr = local.vpc_cidr

  azs             = local.azs
  private_subnets = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 4, k)]
  public_subnets  = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k + 48)]

  enable_nat_gateway = true
  single_nat_gateway = true

  public_subnet_tags = {
    "kubernetes.io/role/elb" = 1
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = 1
  }

  tags = local.tags
}

################################################################################
# Sample App
################################################################################

resource "kubernetes_namespace_v1" "this" {
  metadata {
    name = local.app_name
  }
}

resource "kubernetes_deployment_v1" "this" {
  metadata {
    name      = local.app_name
    namespace = kubernetes_namespace_v1.this.metadata[0].name
  }

  spec {
    replicas = 3

    selector {
      match_labels = {
        "app.kubernetes.io/name" = local.app_name
      }
    }

    template {
      metadata {
        labels = {
          "app.kubernetes.io/name" = local.app_name
        }
      }

      spec {
        container {
          image = "public.ecr.aws/l6m2t8p7/docker-2048:latest"
          # image_pull_policy = "Always"
          name = local.app_name

          port {
            container_port = 80
          }
        }
      }
    }
  }
}

################################################################################
# Resilience Hub Permissions
################################################################################

resource "kubernetes_cluster_role" "resilience_hub_eks_access_cluster_role" {
  metadata {
    name = "resilience-hub-eks-access-cluster-role"
  }

  rule {
    api_groups = [""]
    resources  = ["pods", "replicationcontrollers", "nodes"]
    verbs      = ["get", "list"]
  }

  rule {
    api_groups = ["apps"]
    resources  = ["deployments", "replicasets"]
    verbs      = ["get", "list"]
  }

  rule {
    api_groups = ["policy"]
    resources  = ["poddisruptionbudgets"]
    verbs      = ["get", "list"]
  }

  rule {
    api_groups = ["autoscaling.k8s.io"]
    resources  = ["verticalpodautoscalers"]
    verbs      = ["get", "list"]
  }

  rule {
    api_groups = ["autoscaling"]
    resources  = ["horizontalpodautoscalers"]
    verbs      = ["get", "list"]
  }

  rule {
    api_groups = ["karpenter.sh"]
    resources  = ["provisioners"]
    verbs      = ["get", "list"]
  }

  rule {
    api_groups = ["karpenter.k8s.aws"]
    resources  = ["awsnodetemplates"]
    verbs      = ["get", "list"]
  }
}

resource "kubernetes_cluster_role_binding" "resilience_hub_eks_access_cluster_role_binding" {
  metadata {
    name = "resilience-hub-eks-access-cluster-role-binding"
  }

  subject {
    kind      = "Group"
    name      = "resilience-hub-eks-access-group"
    api_group = "rbac.authorization.k8s.io"
  }

  role_ref {
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role.resilience_hub_eks_access_cluster_role.metadata[0].name
    api_group = "rbac.authorization.k8s.io"
  }
}

resource "kubernetes_config_map_v1_data" "aws_auth" {
  metadata {
    name      = "aws-auth"
    namespace = "kube-system"
  }

  force = true

  data = {
    mapRoles = yamlencode([
      {
        rolearn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${local.arh_role_name}"
        username = "AwsResilienceHubAssessmentEKSAccessRole"
        groups = ["resilience-hub-eks-access-group"]
      },
      {
        rolearn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/Admin"
        username = "Admin-${data.aws_caller_identity.current.user_id}"
        groups = ["admin"]
      }
    ])
  }

}


################################################################################
# Resilience Hub App
################################################################################

resource "random_string" "session" {
  length  = 8
  special = false
}

locals {
  s3_state_file_url = "https://$BUCKET.s3.$BUCKET_REGION.amazonaws.com/$path/to/file.tfstate"
  arh_app_name      = "Application-${random_string.session.id}"
  arh_role_name     = "ArhExecutorRole-${random_string.session.id}"
}

module "resiliencehub_app" {
  app_name       = local.arh_app_name
  source         = "../.."
  rto            = 300
  rpo            = 60
  app_components = [
    {
      app_component_name = "EksDeploymentComponent"
      app_component_type = "AWS::ResilienceHub::ComputeAppComponent"
      resources          = [
        {
          # Must be the deployment name
          resource_name            = "app-2048"
          resource_type            = "AWS::EKS::Deployment"
          # Must be formatted as clusterArn/namespace/uid
          resource_identifier      = "${module.eks.cluster_arn}/${local.app_name}/${kubernetes_deployment_v1.this.metadata[0].uid}"
          resource_identifier_type = "Native"
          resource_region          = "us-west-2"
        }
      ]
    }
  ]
  arh_role_name     = local.arh_role_name
  s3_state_file_url = local.s3_state_file_url
}

