data "aws_iam_policy_document" "thor-eks" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["eks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "thor-eks" {
  name               = "thor-eks"
  assume_role_policy = "${data.aws_iam_policy_document.thor-eks.json}"
}

resource "aws_iam_role_policy_attachment" "thor-eks-AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = "${aws_iam_role.thor-eks.name}"
}

resource "aws_iam_role_policy_attachment" "thor-eks-AmazonEKSServicePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  role       = "${aws_iam_role.thor-eks.name}"
}
