provider "kubernetes" {
  config_context_cluster   = "${aws_eks_cluster.thor-eks.arn}"
  config_context_auth_info = "${aws_eks_cluster.thor-eks.arn}"
  cluster_ca_certificate   = "${base64decode(aws_eks_cluster.thor-eks.certificate_authority.0.data)}"
  host                     = "${aws_eks_cluster.thor-eks.endpoint}"
}

resource "null_resource" "kubectl" {
  triggers = {
    cluster_created_at = "${aws_eks_cluster.thor-eks.created_at}"
  }

  provisioner "local-exec" {
    command = "aws eks update-kubeconfig --name ${aws_eks_cluster.thor-eks.name} --region ${data.aws_region.current.name}"
  }
}
