resource "null_resource" "cni" {
  triggers {
    kubectl_id = "${null_resource.kubectl.id}"
  }

  provisioner "local-exec" {
    command = "kubectl apply -f https://raw.githubusercontent.com/aws/amazon-vpc-cni-k8s/master/config/v1.3/aws-k8s-cni.yaml"
  }
}
