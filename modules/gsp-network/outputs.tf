output "bootstrap-subnet-id" {
  value = "${element(aws_subnet.cluster-private.*.id, 0)}"
}

output "private-subnet-ids" {
  value = ["${aws_subnet.cluster-private.*.id}"]
}

output "cluster-name" {
  value = "${var.cluster_name}"
}

output "host_cidr" {
  description = "CIDR IPv4 range to assign to EC2 nodes"
  value       = "${var.host_cidr}"
}
