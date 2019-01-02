data "aws_ami" "eks-worker" {
  filter {
    name   = "name"
    values = ["amazon-eks-node-v*"]
  }

  most_recent = true
  owners      = ["602401143452"] # Amazon EKS AMI Account ID
}

data "aws_region" "current" {}

locals {
  eks-worker-userdata = <<USERDATA
#!/bin/bash
set -o trace
/etc/eks/bootstrap.sh \
  --apiserver-endpoint '${aws_eks_cluster.thor-eks.endpoint}' \
  --b64-cluster-ca '${aws_eks_cluster.thor-eks.certificate_authority.0.data}' \
  --kubelet-extra-args '--network-plugin=cni --cni-conf-dir=/etc/cni/net.d --cni-bin-dir=/opt/cni/bin' \
  '${var.cluster-name}'
USERDATA
}

resource "aws_launch_configuration" "thor-eks-worker" {
  associate_public_ip_address = true
  iam_instance_profile        = "${aws_iam_instance_profile.thor-eks.name}"
  image_id                    = "${data.aws_ami.eks-worker.id}"
  instance_type               = "m4.large"
  name_prefix                 = "thor-eks"
  security_groups             = ["${aws_security_group.thor-eks-worker.id}"]
  user_data_base64            = "${base64encode(local.eks-worker-userdata)}"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "thor-eks" {
  desired_capacity     = 2
  launch_configuration = "${aws_launch_configuration.thor-eks-worker.id}"
  max_size             = 3
  min_size             = 1
  name                 = "${aws_launch_configuration.thor-eks-worker.name}-asg"
  vpc_zone_identifier  = ["${aws_subnet.thor-eks.*.id}"]

  tag {
    key                 = "Name"
    value               = "thor-eks-worker"
    propagate_at_launch = true
  }

  tag {
    key                 = "kubernetes.io/cluster/${var.cluster-name}"
    value               = "owned"
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
  }
}
