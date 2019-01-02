data "aws_iam_policy_document" "thor-eks-worker" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "thor-eks-worker" {
  name               = "thor-eks-worker"
  assume_role_policy = "${data.aws_iam_policy_document.thor-eks-worker.json}"
}

resource "aws_iam_role_policy_attachment" "thor-eks-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = "${aws_iam_role.thor-eks-worker.name}"
}

resource "aws_iam_role_policy_attachment" "thor-eks-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = "${aws_iam_role.thor-eks-worker.name}"
}

resource "aws_iam_role_policy_attachment" "thor-eks-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = "${aws_iam_role.thor-eks-worker.name}"
}

resource "aws_iam_instance_profile" "thor-eks" {
  name = "thor-eks"
  role = "${aws_iam_role.thor-eks-worker.name}"
}
