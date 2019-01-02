resource "aws_eks_cluster" "thor-eks" {
  name     = "${var.cluster-name}"
  role_arn = "${aws_iam_role.thor-eks.arn}"

  vpc_config {
    security_group_ids = ["${aws_security_group.thor-eks.id}"]
    subnet_ids         = ["${aws_subnet.thor-eks.*.id}"]
  }

  depends_on = [
    "aws_iam_role_policy_attachment.thor-eks-AmazonEKSClusterPolicy",
    "aws_iam_role_policy_attachment.thor-eks-AmazonEKSServicePolicy",
  ]
}
