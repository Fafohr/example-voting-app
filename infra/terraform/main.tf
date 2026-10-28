terraform {
  required_version = ">= 1.5.7"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.59, < 7.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

data "aws_subnet" "default" {
  for_each = toset(data.aws_subnets.default.ids)
  id       = each.value
}

resource "terraform_data" "validate_default_vpc" {
  input = data.aws_subnets.default.ids

  lifecycle {
    precondition {
      condition = length(distinct([
        for subnet in data.aws_subnet.default : subnet.availability_zone
      ])) >= 2
      error_message = "The AWS default VPC must have subnets in at least two Availability Zones for EKS."
    }
  }
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "21.29.0"

  name               = var.cluster_name
  kubernetes_version = var.kubernetes_version

  endpoint_public_access                   = true
  endpoint_public_access_cidrs             = var.cluster_endpoint_public_access_cidrs
  enable_cluster_creator_admin_permissions = true

  compute_config = {
    enabled = false
  }

  vpc_id     = data.aws_vpc.default.id
  subnet_ids = data.aws_subnets.default.ids

  eks_managed_node_groups = {
    default = {
      ami_type       = "AL2023_x86_64_STANDARD"
      instance_types = [var.node_instance_type]
      min_size       = 1
      max_size       = 2
      desired_size   = 1
    }
  }

  tags = {
    Environment = "dev"
    ManagedBy   = "terraform"
    Project     = "example-voting-app"
  }

  depends_on = [terraform_data.validate_default_vpc]
}
