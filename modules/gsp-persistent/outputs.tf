output "private-subnet-ids" {
  value = ["${aws_subnet.cluster-private.*.id}"]
}

output "cert_pem" {
  description = "Sealed secrets certificate"
  value       = "${module.gsp-persistent.cert_pem}"
}

output "private_key_pem" {
  description = "Sealed secrets private key"
  value       = "${module.gsp-persistent.private_key_pem}"
}
