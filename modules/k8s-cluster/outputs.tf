output "kubeconfig" {
  value = "${data.template_file.kubeconfig.rendered}"
}

output "kiam-server-node-instance-role-arn" {
  value = "${aws_cloudformation_stack.kiam-server-nodes.outputs["NodeInstanceRole"]}"
}

output "bootstrap_role_arns" {
  value = "${list(aws_cloudformation_stack.worker-nodes.outputs["NodeInstanceRole"], aws_cloudformation_stack.kiam-server-nodes.outputs["NodeInstanceRole"], aws_cloudformation_stack.ci-nodes.outputs["NodeInstanceRole"])}"
}
