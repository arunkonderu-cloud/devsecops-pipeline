variable "cluster_name" {
  description = "Name of the EKS cluster."
  type        = string
}

variable "kubernetes_version" {
  description = "Kubernetes version for the control plane."
  type        = string
  default     = "1.33"
}

variable "private_subnet_ids" {
  description = "Private subnet IDs (at least two, in different AZs) for the control plane ENIs and worker nodes."
  type        = list(string)

  validation {
    condition     = length(var.private_subnet_ids) >= 2
    error_message = "Provide at least two private subnets in different availability zones."
  }
}

variable "public_access_cidrs" {
  description = "CIDRs allowed to reach the public API endpoint. Leave empty to keep the endpoint private-only."
  type        = list(string)
  default     = []

  validation {
    condition     = !contains(var.public_access_cidrs, "0.0.0.0/0")
    error_message = "Opening the API endpoint to 0.0.0.0/0 is not allowed."
  }
}

variable "node_instance_types" {
  description = "Instance types for the managed node group."
  type        = list(string)
  default     = ["m6i.large"]
}

variable "node_desired_size" {
  type    = number
  default = 3
}

variable "node_min_size" {
  type    = number
  default = 2
}

variable "node_max_size" {
  type    = number
  default = 6
}

variable "log_retention_days" {
  description = "Retention for control plane logs."
  type        = number
  default     = 365
}

variable "tags" {
  description = "Tags applied to all resources."
  type        = map(string)
  default     = {}
}
