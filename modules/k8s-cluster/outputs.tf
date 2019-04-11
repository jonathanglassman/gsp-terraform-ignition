output "kubeconfig" {
  value = "${data.template_file.kubeconfig.rendered}"
}

output "kiam-server-node-instance-role-arn" {
  value = "${aws_cloudformation_stack.kiam-server-nodes.outputs["NodeInstanceRole"]}"
}
