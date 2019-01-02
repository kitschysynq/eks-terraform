resource "aws_security_group" "thor-eks-worker" {
  name        = "${var.network-name}-worker"
  description = "Security group for all nodes in the cluster"
  vpc_id      = "${aws_vpc.thor-eks.id}"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = "${
    map(
      "Name", "${var.network-name}",
      "kubernetes.io/cluster/${var.cluster-name}", "owned",
    )
  }"
}

resource "aws_security_group_rule" "thor-eks-ingress-self" {
  description              = "Allow nodes to communicate with each other"
  from_port                = 0
  protocol                 = "-1"
  security_group_id        = "${aws_security_group.thor-eks-worker.id}"
  source_security_group_id = "${aws_security_group.thor-eks-worker.id}"
  to_port                  = 65535
  type                     = "ingress"
}

resource "aws_security_group_rule" "thor-eks-ingress-cluster" {
  description              = "Allow worker kubelets and pods to communicate with k8s API"
  from_port                = 1025
  protocol                 = "tcp"
  security_group_id        = "${aws_security_group.thor-eks-worker.id}"
  source_security_group_id = "${aws_security_group.thor-eks.id}"
  to_port                  = 65535
  type                     = "ingress"
}

resource "aws_security_group_rule" "thor-eks-ingress-worker-https" {
  description              = "Allow pods to query k8s API"
  from_port                = 443
  protocol                 = "tcp"
  security_group_id        = "${aws_security_group.thor-eks.id}"
  source_security_group_id = "${aws_security_group.thor-eks-worker.id}"
  to_port                  = 443
  type                     = "ingress"
}

resource "aws_security_group_rule" "thor-eks-ingress-api-https" {
  description              = "Allow k8s master to query worker https"
  from_port                = 443
  protocol                 = "tcp"
  security_group_id        = "${aws_security_group.thor-eks-worker.id}"
  source_security_group_id = "${aws_security_group.thor-eks.id}"
  to_port                  = 443
  type                     = "ingress"
}
