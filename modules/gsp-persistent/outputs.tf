output "private-subnet-ids" {
  value = ["${aws_subnet.cluster-private.*.id}"]
}
