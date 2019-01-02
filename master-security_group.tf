variable "access_from" {
  type = "list"
}

resource "aws_security_group" "thor-eks" {
  name        = "${var.network-name}"
  description = "Cluster communication with worker nodes"
  vpc_id      = "${aws_vpc.thor-eks.id}"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "${var.network-name}"
  }
}

resource "aws_security_group_rule" "thor-eks-ingress-workstation-https" {
  cidr_blocks       = "${var.access_from}"
  description       = "Allow thor to hit cluster API from home office"
  from_port         = 443
  protocol          = "tcp"
  security_group_id = "${aws_security_group.thor-eks.id}"
  to_port           = 443
  type              = "ingress"
}
