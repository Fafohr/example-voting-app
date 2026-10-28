variable "aws_region" {
  description = "AWS region containing the default VPC."
  type        = string
}

variable "cluster_name" {
  description = "Name assigned to the EKS cluster."
  type        = string
  default     = "example-voting-app"
}

variable "kubernetes_version" {
  description = "EKS Kubernetes version. Check AWS support before upgrading."
  type        = string
  default     = "1.37"
}

variable "node_instance_type" {
  description = "EC2 instance type used by the single initial managed node."
  type        = string
  default     = "t3.medium"
}

variable "cluster_endpoint_public_access_cidrs" {
  description = "IPv4 CIDR blocks allowed to reach the public Kubernetes API endpoint."
  type        = list(string)

  validation {
    condition = (
      length(var.cluster_endpoint_public_access_cidrs) > 0 &&
      !contains(var.cluster_endpoint_public_access_cidrs, "0.0.0.0/0") &&
      !contains(var.cluster_endpoint_public_access_cidrs, "::/0")
    )
    error_message = "Provide at least one restricted CIDR; public access from all IP addresses is not allowed."
  }
}
