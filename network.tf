provider "aws" {
  region = "us-east-1"
}

data "aws_availability_zones" "available" {}

variable "cluster-name" {
  default = "thor-eks"
  type    = "string"
}

variable "network-name" {
  default = "thor-dev-eks"
  type    = "string"
}

resource "aws_vpc" "thor-eks" {
  cidr_block = "10.0.0.0/16"

  tags = "${
		map(
			"Name", "${var.network-name}",
			"kubernetes.io/cluster/${var.cluster-name}", "shared",
		)
	}"
}

resource "aws_subnet" "thor-eks" {
  count = 2

  availability_zone = "${data.aws_availability_zones.available.names[count.index]}"
  cidr_block        = "10.0.${count.index}.0/24"
  vpc_id            = "${aws_vpc.thor-eks.id}"

  tags = "${
		map(
			"Name", "${var.network-name}",
			"kubernetes.io/cluster/${var.cluster-name}", "shared",
		)
	}"
}

resource "aws_internet_gateway" "thor-eks" {
  vpc_id = "${aws_vpc.thor-eks.id}"

  tags {
    Name = "${var.network-name}"
  }
}

resource "aws_route_table" "thor-eks" {
  vpc_id = "${aws_vpc.thor-eks.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.thor-eks.id}"
  }
}

resource "aws_route_table_association" "thor-eks" {
  count = 2

  subnet_id      = "${aws_subnet.thor-eks.*.id[count.index]}"
  route_table_id = "${aws_route_table.thor-eks.id}"
}
