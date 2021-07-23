variable "fargate_profile_name" {
  type        = string
  description = "Name of the Fargate Profile"
}

variable "eks_cluster_name" {
  description = "Name of the EKS Cluster"
}

variable "subnet_ids" {
  type        = list(string)
  description = "List of all the Subnets"
}

variable "fargate_namespaces" {
  type        = list(string)
  description = "The list of namespaces where the fargate profile must be enabled"
}

variable "environment" {
  description = "The name of the environment"
}
