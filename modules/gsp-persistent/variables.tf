variable "cluster_name" {
  description = "Cluster name"
  type        = "string"
}

variable "dns_zone" {
  description = "DNS zone"
  type        = "string"
}

variable "host_cidr" {
  description = "CIDR IPv4 range to assign to EC2 nodes"
  type        = "string"
  default     = "10.0.0.0/16"
}
