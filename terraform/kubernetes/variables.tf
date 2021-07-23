variable "region" {
  type        = string
  description = "AWS Region"
}

variable "vpc_id" {
  type        = string
  description = "EKS Cluster VPC ID"
}

variable "cidr" {
  type        = string
  description = "VPC CIDR Block"
}

variable "eks_cluster_name" {
  description = "Name of the EKS Cluster"
}

variable "efs_subnet_ids" {
  type        = list(string)
  description = "Subnets ID's for EFS Mount Targets"
}

variable "fargate_namespaces" {
  type        = list(string)
  description = "Kubernetes namespaces for fargate profiles"
}

variable "eks_cluster_endpoint" {
  type        = string
  description = "EKS Cluster Endpoint"
}

variable "eks_oidc_url" {
  type        = string
  description = "EKS Cluster OIDC Provider URL"
}

variable "eks_ca_certificate" {
  type        = string
  description = "EKS Cluster CA Certificate"
}

variable "environment" {
  description = "The name of the environment"
}
