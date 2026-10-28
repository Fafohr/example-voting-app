output "cluster_name" {
  description = "Name of the EKS cluster."
  value       = var.cluster_name
}

output "aws_region" {
  description = "AWS region hosting the cluster."
  value       = var.aws_region
}

output "kubectl_configure_command" {
  description = "Command to add this cluster to the local kubeconfig."
  value = format(
    "aws eks update-kubeconfig --region %s --name %s",
    var.aws_region,
    var.cluster_name
  )
}
