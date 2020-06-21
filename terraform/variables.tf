variable "region" {
  default     = "us-central-1"
  description = "AWS region"
}

variable "cluster_count" {
  default     = 2
  description = "Number of clusters to create"
}
