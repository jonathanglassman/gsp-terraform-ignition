resource "null_resource" "metrics-server" {
    provisioner "file" {
        source      = "${file("${path.module}/data/metrics-server/auth-delegator.yaml")}"
        destination = "addons/${var.cluster_name}/metrics-server/auth-delegator.yaml"
    }

    provisioner "file" {
        source      = "${file("${path.module}/data/metrics-server/auth-reader.yaml")}"
        destination = "addons/${var.cluster_name}/metrics-server/auth-reader.yaml"
    }

    provisioner "file" {
        source      = "${file("${path.module}/data/metrics-server/metrics-apiservice.yaml")}"
        destination = "addons/${var.cluster_name}/metrics-server/metrics-apiservice.yaml"
    }

    provisioner "file" {
        source      = "${file("${path.module}/data/metrics-server/metrics-server-deployment.yaml")}"
        destination = "addons/${var.cluster_name}/metrics-server/metrics-server-deployment.yaml"
    }

    provisioner "file" {
        source      = "${file("${path.module}/data/metrics-server/metrics-server-service.yaml")}"
        destination = "addons/${var.cluster_name}/metrics-server/metrics-server-service.yaml"
    }

    provisioner "file" {
        source      = "${file("${path.module}/data/metrics-server/resource-reader.yaml")}"
        destination = "addons/${var.cluster_name}/metrics-server/resource-reader.yaml"
    }    
}
